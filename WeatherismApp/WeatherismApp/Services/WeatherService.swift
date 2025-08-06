//
//  WeatherService.swift
//  WeatherismApp
//
//  Created by Agustinus Pongoh on 05/08/25.
//

import Foundation

// MARK: - Weather Service Protocol
protocol WeatherServiceProtocol {
    func fetchWeather(for city: String) async throws -> (WeatherResponse, GeocodingResult)
}

// MARK: - Weather Service Implementation
class WeatherService: WeatherServiceProtocol {
    private let weatherBaseURL = "https://api.open-meteo.com/v1/forecast"
    private let geocodingBaseURL = "https://geocoding-api.open-meteo.com/v1/search"
    
    func fetchWeather(for city: String) async throws -> (WeatherResponse, GeocodingResult) {
        // First, get coordinates for the city
        let location = try await geocodeCity(city)
        let weather = try await fetchWeatherData(latitude: location.latitude, longitude: location.longitude)
        return (weather, location)
    }
    
    private func geocodeCity(_ city: String) async throws -> GeocodingResult {
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = "\(geocodingBaseURL)?name=\(encodedCity)&count=1&language=en&format=json"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let geocodingResponse = try JSONDecoder().decode(GeocodingResponse.self, from: data)
        
        guard let location = geocodingResponse.results?.first else {
            throw NetworkError.cityNotFound
        }
        
        return location
    }
    
    private func fetchWeatherData(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        let urlString = "\(weatherBaseURL)?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,relative_humidity_2m,apparent_temperature,wind_speed_10m,wind_direction_10m,weather_code&daily=temperature_2m_max,temperature_2m_min&hourly=temperature_2m&timezone=auto"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
        return weatherResponse
    }
    
    // MARK: - Wedding Planning Service Methods
    func fetchWeatherForDate(latitude: Double, longitude: Double, date: Date) async throws -> WeatherResponse {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        let urlString = "\(weatherBaseURL)?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,relative_humidity_2m,apparent_temperature,wind_speed_10m,wind_direction_10m,weather_code&daily=temperature_2m_max,temperature_2m_min&hourly=temperature_2m&timezone=auto&start_date=\(dateString)&end_date=\(dateString)"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
        return weatherResponse
    }
    
    func fetchWeddingForecast(for city: String, date: Date) async throws -> WeddingForecast {
        let location = try await geocodeCity(city)
        let weather = try await fetchWeatherForDate(latitude: location.latitude, longitude: location.longitude, date: date)
        let suitability = assessWeddingSuitability(weather: weather)
        
        return WeddingForecast(date: date, weather: weather, suitability: suitability, location: location)
    }
    
    func fetchAlternativeWeddingDates(for city: String, around targetDate: Date) async throws -> [WeddingForecast] {
        let location = try await geocodeCity(city)
        var alternatives: [WeddingForecast] = []
        
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -7, to: targetDate) ?? targetDate
        let endDate = calendar.date(byAdding: .day, value: 7, to: targetDate) ?? targetDate
        
        var currentDate = startDate
        while currentDate <= endDate && !calendar.isDate(currentDate, inSameDayAs: targetDate) {
            do {
                let weather = try await fetchWeatherForDate(latitude: location.latitude, longitude: location.longitude, date: currentDate)
                let suitability = assessWeddingSuitability(weather: weather)
                
                let forecast = WeddingForecast(date: currentDate, weather: weather, suitability: suitability, location: location)
                alternatives.append(forecast)
            } catch {
                // Skip dates with errors
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        // Sort by date proximity to target date, with good weather prioritized
        return alternatives.sorted { first, second in
            let firstScore = weddingDateScore(for: first, targetDate: targetDate)
            let secondScore = weddingDateScore(for: second, targetDate: targetDate)
            return firstScore > secondScore
        }
    }
    
    private func assessWeddingSuitability(weather: WeatherResponse) -> WeddingSuitability {
        let weatherCode = weather.current.weatherCode
        let temp = weather.current.temperature2m
        let windSpeed = weather.current.windSpeed10m
        let humidity = weather.current.relativeHumidity2m
        
        // Check for rain or storms
        if [61, 63, 65, 80, 81, 82, 95, 96, 99].contains(weatherCode) {
            return .unsuitable
        }
        
        // Check for drizzle or light precipitation
        if [51, 53, 55, 56, 57].contains(weatherCode) {
            return .risky
        }
        
        // Check temperature ranges (ideal 18-26°C)
        if temp < 10 || temp > 32 {
            return .risky
        }
        
        // Check wind speed (problematic if > 25 km/h)
        if windSpeed > 25 {
            return .risky
        }
        
        // Perfect conditions: clear skies, good temperature, low wind
        if [0, 1].contains(weatherCode) && temp >= 18 && temp <= 26 && windSpeed < 15 && humidity < 70 {
            return .perfect
        }
        
        // Good conditions: partly cloudy but acceptable
        if [2, 3].contains(weatherCode) && temp >= 15 && temp <= 28 && windSpeed < 20 {
            return .good
        }
        
        return .good
    }
    
    private func weddingDateScore(for forecast: WeddingForecast, targetDate: Date) -> Double {
        let calendar = Calendar.current
        let daysDifference = abs(calendar.dateComponents([.day], from: targetDate, to: forecast.date).day ?? 0)
        
        // Weather quality score
        let weatherScore: Double = switch forecast.suitability {
        case .perfect: 100
        case .good: 75
        case .risky: 40
        case .unsuitable: 10
        }
        
        // Date proximity score (closer to target is better)
        let proximityScore = max(0, 50 - Double(daysDifference) * 5)
        
        return weatherScore + proximityScore
    }
}
