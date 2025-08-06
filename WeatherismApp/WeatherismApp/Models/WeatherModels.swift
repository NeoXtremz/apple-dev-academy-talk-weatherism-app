//
//  WeatherModels.swift
//  WeatherismApp
//
//  Created by Agustinus Pongoh on 05/08/25.
//

import Foundation

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
    let uvIndex: Double?
    let pm25: Double?
    let pm10: Double?
    let carbonMonoxide: Double?
    let nitrogenDioxide: Double?
    let sulphurDioxide: Double?
    let ozone: Double?
    
    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case relativeHumidity2m = "relative_humidity_2m"
        case apparentTemperature = "apparent_temperature"
        case windSpeed10m = "wind_speed_10m"
        case windDirection10m = "wind_direction_10m"
        case weatherCode = "weather_code"
        case uvIndex = "uv_index"
        case pm25 = "pm2_5"
        case pm10 = "pm10"
        case carbonMonoxide = "carbon_monoxide"
        case nitrogenDioxide = "nitrogen_dioxide"
        case sulphurDioxide = "sulphur_dioxide"
        case ozone
    }
}

struct DailyWeather: Codable {
    let time: [String]
    let temperature2mMax: [Double]
    let temperature2mMin: [Double]
    let uvIndexMax: [Double]?
    
    enum CodingKeys: String, CodingKey {
        case time
        case temperature2mMax = "temperature_2m_max"
        case temperature2mMin = "temperature_2m_min"
        case uvIndexMax = "uv_index_max"
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

// MARK: - Air Quality Models
struct AirQualityResponse: Codable {
    let current: CurrentAirQuality
}

struct CurrentAirQuality: Codable {
    let pm25: Double?
    let pm10: Double?
    let carbonMonoxide: Double?
    let nitrogenDioxide: Double?
    let sulphurDioxide: Double?
    let ozone: Double?
    
    enum CodingKeys: String, CodingKey {
        case pm25 = "pm2_5"
        case pm10 = "pm10"
        case carbonMonoxide = "carbon_monoxide"
        case nitrogenDioxide = "nitrogen_dioxide"
        case sulphurDioxide = "sulphur_dioxide"
        case ozone
    }
}

// MARK: - UV Index Helper
enum UVIndexLevel {
    case low
    case moderate
    case high
    case veryHigh
    case extreme
    
    init(uvIndex: Double) {
        switch uvIndex {
        case 0...2:
            self = .low
        case 3...5:
            self = .moderate
        case 6...7:
            self = .high
        case 8...10:
            self = .veryHigh
        default:
            self = .extreme
        }
    }
    
    var description: String {
        switch self {
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .high: return "High"
        case .veryHigh: return "Very High"
        case .extreme: return "Extreme"
        }
    }
    
    var warning: String? {
        switch self {
        case .low, .moderate:
            return nil
        case .high:
            return "Wear sunscreen and protective clothing ☀️"
        case .veryHigh:
            return "Avoid sun exposure between 10 AM - 4 PM 🧴"
        case .extreme:
            return "Stay indoors! Dangerous UV levels ⚠️"
        }
    }
    
    var color: String {
        switch self {
        case .low: return "green"
        case .moderate: return "yellow"
        case .high: return "orange"
        case .veryHigh: return "red"
        case .extreme: return "purple"
        }
    }
}

// MARK: - Air Quality Helper
enum AirQualityLevel {
    case good
    case moderate
    case unhealthyForSensitive
    case unhealthy
    case veryUnhealthy
    case hazardous
    
    init(pm25: Double) {
        switch pm25 {
        case 0...12:
            self = .good
        case 13...35:
            self = .moderate
        case 36...55:
            self = .unhealthyForSensitive
        case 56...150:
            self = .unhealthy
        case 151...250:
            self = .veryUnhealthy
        default:
            self = .hazardous
        }
    }
    
    var description: String {
        switch self {
        case .good: return "Good"
        case .moderate: return "Moderate"
        case .unhealthyForSensitive: return "Unhealthy for Sensitive Groups"
        case .unhealthy: return "Unhealthy"
        case .veryUnhealthy: return "Very Unhealthy"
        case .hazardous: return "Hazardous"
        }
    }
    
    var warning: String? {
        switch self {
        case .good, .moderate:
            return nil
        case .unhealthyForSensitive:
            return "Sensitive people should limit outdoor activities 😷"
        case .unhealthy:
            return "Everyone should limit outdoor activities 🚫"
        case .veryUnhealthy:
            return "Avoid outdoor activities! 🏠"
        case .hazardous:
            return "Emergency conditions! Stay indoors! ⚠️"
        }
    }
    
    var color: String {
        switch self {
        case .good: return "green"
        case .moderate: return "yellow"
        case .unhealthyForSensitive: return "orange"
        case .unhealthy: return "red"
        case .veryUnhealthy: return "purple"
        case .hazardous: return "maroon"
        }
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
import SwiftUI

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
