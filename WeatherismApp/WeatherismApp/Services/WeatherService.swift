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
    private let airQualityBaseURL = "https://air-quality-api.open-meteo.com/v1/air-quality"
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
        // Combine weather and air quality data
        async let weatherTask = fetchWeatherOnly(latitude: latitude, longitude: longitude)
        async let airQualityTask = fetchAirQuality(latitude: latitude, longitude: longitude)
        
        let weather = try await weatherTask
        let airQuality = try? await airQualityTask
        
        // Merge air quality data into weather response
        let enhancedCurrent = CurrentWeather(
            time: weather.current.time,
            temperature2m: weather.current.temperature2m,
            relativeHumidity2m: weather.current.relativeHumidity2m,
            apparentTemperature: weather.current.apparentTemperature,
            windSpeed10m: weather.current.windSpeed10m,
            windDirection10m: weather.current.windDirection10m,
            weatherCode: weather.current.weatherCode,
            uvIndex: weather.current.uvIndex,
            pm25: airQuality?.current.pm25,
            pm10: airQuality?.current.pm10,
            carbonMonoxide: airQuality?.current.carbonMonoxide,
            nitrogenDioxide: airQuality?.current.nitrogenDioxide,
            sulphurDioxide: airQuality?.current.sulphurDioxide,
            ozone: airQuality?.current.ozone
        )
        
        return WeatherResponse(
            current: enhancedCurrent,
            daily: weather.daily,
            hourly: weather.hourly
        )
    }
    
    private func fetchWeatherOnly(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        let urlString = "\(weatherBaseURL)?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,relative_humidity_2m,apparent_temperature,wind_speed_10m,wind_direction_10m,weather_code,uv_index&daily=temperature_2m_max,temperature_2m_min,uv_index_max&hourly=temperature_2m&timezone=auto"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
        return weatherResponse
    }
    
    private func fetchAirQuality(latitude: Double, longitude: Double) async throws -> AirQualityResponse {
        let urlString = "\(airQualityBaseURL)?latitude=\(latitude)&longitude=\(longitude)&current=pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let airQualityResponse = try JSONDecoder().decode(AirQualityResponse.self, from: data)
        return airQualityResponse
    }
}
