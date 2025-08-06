//
//  WeatherModels.swift
//  WeatherismApp
//
//  Created by Agustinus Pongoh on 05/08/25.
//

import Foundation
import SwiftUI

// MARK: - Weather Data Models
struct WeatherResponse: Codable {
    let current: CurrentWeather
    let daily: DailyWeather
    let hourly: HourlyWeather
}

struct CurrentWeather: Codable {
    let time: String
    let temperature2m: Double
    let relativeHumidity2m: Int
    let apparentTemperature: Double
    let windSpeed10m: Double
    let windDirection10m: Double
    let weatherCode: Int
    
    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case relativeHumidity2m = "relative_humidity_2m"
        case apparentTemperature = "apparent_temperature"
        case windSpeed10m = "wind_speed_10m"
        case windDirection10m = "wind_direction_10m"
        case weatherCode = "weather_code"
    }
}

struct DailyWeather: Codable {
    let time: [String]
    let temperature2mMax: [Double]
    let temperature2mMin: [Double]
    
    enum CodingKeys: String, CodingKey {
        case time
        case temperature2mMax = "temperature_2m_max"
        case temperature2mMin = "temperature_2m_min"
    }
}

struct HourlyWeather: Codable {
    let time: [String]
    let temperature2m: [Double]
    
    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
    }
}

// MARK: - Geocoding Models
struct GeocodingResponse: Codable {
    let results: [GeocodingResult]?
}

struct GeocodingResult: Codable {
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String
    let countryCode: String
    
    enum CodingKeys: String, CodingKey {
        case name, latitude, longitude, country
        case countryCode = "country_code"
    }
}

// MARK: - Weather Condition Types
enum WeatherCondition: CaseIterable {
    case clear
    case partlyCloudy
    case cloudy
    case foggy
    case drizzle
    case rainy
    case snowy
    case stormy
    
    var displayName: String {
        switch self {
        case .clear: return "Clear"
        case .partlyCloudy: return "Partly Cloudy"
        case .cloudy: return "Cloudy"
        case .foggy: return "Foggy"
        case .drizzle: return "Drizzle"
        case .rainy: return "Rainy"
        case .snowy: return "Snowy"
        case .stormy: return "Stormy"
        }
    }
}

// MARK: - Weather Background Extension
extension WeatherCondition {
    var backgroundGradient: LinearGradient {
        switch self {
        case .clear:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.orange.opacity(0.8),
                    Color.yellow.opacity(0.6),
                    Color.blue.opacity(0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .partlyCloudy:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.7),
                    Color.orange.opacity(0.5),
                    Color.purple.opacity(0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .cloudy:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.gray.opacity(0.8),
                    Color.blue.opacity(0.5),
                    Color.gray.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .foggy:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.gray.opacity(0.9),
                    Color.white.opacity(0.7),
                    Color.gray.opacity(0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .drizzle:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.gray.opacity(0.7),
                    Color.blue.opacity(0.5),
                    Color.purple.opacity(0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .rainy:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.gray.opacity(0.9),
                    Color.blue.opacity(0.7),
                    Color.indigo.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .snowy:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.9),
                    Color.blue.opacity(0.4),
                    Color.cyan.opacity(0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .stormy:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.8),
                    Color.purple.opacity(0.7),
                    Color.indigo.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Network Errors
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case cityNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .cityNotFound:
            return "City not found. Please check the spelling and try again."
        }
    }
}

// MARK: - Wedding Planning Models
enum WeddingSuitability {
    case perfect      // Clear, ideal conditions
    case good        // Acceptable conditions
    case risky       // Some weather concerns
    case unsuitable  // Poor weather conditions
    
    var title: String {
        switch self {
        case .perfect: return "Perfect Wedding Weather! 💕"
        case .good: return "Good Wedding Weather ✨"
        case .risky: return "Weather Concerns ⚠️"
        case .unsuitable: return "Not Ideal for Outdoor Wedding 🌧️"
        }
    }
    
    var message: String {
        switch self {
        case .perfect: return "The weather is absolutely perfect for your special day! Clear skies and comfortable temperatures await."
        case .good: return "Great conditions for your wedding celebration! Some clouds but perfect for photos."
        case .risky: return "Weather might pose some challenges. Consider having backup plans ready."
        case .unsuitable: return "Outdoor conditions aren't ideal. We recommend alternative dates below."
        }
    }
    
    var color: Color {
        switch self {
        case .perfect: return Color(red: 1.0, green: 0.8, blue: 0.9) // Soft pink
        case .good: return Color(red: 0.9, green: 0.95, blue: 1.0) // Soft blue
        case .risky: return Color(red: 1.0, green: 0.95, blue: 0.8) // Soft yellow
        case .unsuitable: return Color(red: 0.95, green: 0.9, blue: 0.9) // Soft gray
        }
    }
    
    var iconName: String {
        switch self {
        case .perfect: return "heart.fill"
        case .good: return "sun.max.fill"
        case .risky: return "cloud.sun.fill"
        case .unsuitable: return "cloud.rain.fill"
        }
    }
}

struct WeddingForecast {
    let date: Date
    let weather: WeatherResponse
    let suitability: WeddingSuitability
    let location: GeocodingResult
}

struct WeddingPlan {
    let selectedDate: Date
    let venue: String
    let forecast: WeddingForecast?
    let alternativeDates: [WeddingForecast]
}
