//
//  WeatherView.swift
//  WeatherismApp
//
//  Created by Agustinus Pongoh on 05/08/25.
//

import SwiftUI

// MARK: - Weather View
struct WeatherView: View {
    let weather: WeatherResponse
    let viewModel: WeatherViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Location Header
                locationHeader
                
                // Main Weather Display
                mainWeatherDisplay
                
                // Warnings Section
                warningsSection
                
                // Weather Details Grid
                weatherDetailsGrid
                
                // Health Indices Section
                healthIndicesSection
            }
            .padding()
        }
    }
    
    // MARK: - Location Header
    private var locationHeader: some View {
        HStack {
            Image(systemName: "location.fill")
                .foregroundColor(.white.opacity(0.8))
            Text(viewModel.locationDisplayName)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Main Weather Display
    private var mainWeatherDisplay: some View {
        VStack(spacing: 16) {
            // Weather Icon and Description
            VStack(spacing: 12) {
                Image(systemName: viewModel.weatherIconName(for: weather.current.weatherCode))
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                
                Text(viewModel.weatherDescription(for: weather.current.weatherCode))
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            
            // Temperature Display
            VStack(spacing: 8) {
                Text("\(Int(weather.current.temperature2m))°C")
                    .font(.system(size: 72, weight: .ultraLight, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Feels like \(Int(weather.current.apparentTemperature))°C")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    // MARK: - Warnings Section
    private var warningsSection: some View {
        VStack(spacing: 12) {
            // General Weather Reminder
            if let reminder = generalReminder {
                WarningCard(
                    text: reminder,
                    icon: "info.circle.fill",
                    color: .blue
                )
            }
            
            // UV Index Warning
            if let uvIndex = weather.current.uvIndex {
                let uvLevel = UVIndexLevel(uvIndex: uvIndex)
                if let uvWarning = uvLevel.warning {
                    WarningCard(
                        text: uvWarning,
                        icon: "sun.max.fill",
                        color: colorForUVLevel(uvLevel)
                    )
                }
            }
            
            // Air Quality Warning
            if let pm25 = weather.current.pm25 {
                let aqLevel = AirQualityLevel(pm25: pm25)
                if let aqWarning = aqLevel.warning {
                    WarningCard(
                        text: aqWarning,
                        icon: "lungs.fill",
                        color: colorForAQLevel(aqLevel)
                    )
                }
            }
        }
    }
    
    // MARK: - Weather Details Grid
    private var weatherDetailsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
            WeatherDetailCard(
                icon: "thermometer.low",
                title: "Min Temp",
                value: "\(Int(weather.daily.temperature2mMin.first ?? 0))°C"
            )
            
            WeatherDetailCard(
                icon: "thermometer.high",
                title: "Max Temp",
                value: "\(Int(weather.daily.temperature2mMax.first ?? 0))°C"
            )
            
            WeatherDetailCard(
                icon: "humidity.fill",
                title: "Humidity",
                value: "\(weather.current.relativeHumidity2m)%"
            )
            
            WeatherDetailCard(
                icon: "wind",
                title: "Wind Speed",
                value: "\(String(format: "%.1f", weather.current.windSpeed10m)) km/h"
            )
        }
    }
    
    // MARK: - Health Indices Section
    private var healthIndicesSection: some View {
        VStack(spacing: 16) {
            Text("Health Indices")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                // UV Index
                if let uvIndex = weather.current.uvIndex {
                    let uvLevel = UVIndexLevel(uvIndex: uvIndex)
                    HealthIndexCard(
                        icon: "sun.max.fill",
                        title: "UV Index",
                        value: "\(Int(uvIndex))",
                        level: uvLevel.description,
                        color: colorForUVLevel(uvLevel)
                    )
                }
                
                // Air Quality Index
                if let pm25 = weather.current.pm25 {
                    let aqLevel = AirQualityLevel(pm25: pm25)
                    HealthIndexCard(
                        icon: "lungs.fill",
                        title: "Air Quality (PM2.5)",
                        value: "\(Int(pm25)) µg/m³",
                        level: aqLevel.description,
                        color: colorForAQLevel(aqLevel)
                    )
                }
            }
        }
    }
    
    // MARK: - Helper Computed Properties
    private var generalReminder: String? {
        let temp = weather.current.temperature2m
        let weatherCode = weather.current.weatherCode
        let isRaining = viewModel.weatherCondition(for: weatherCode) == .rainy
        
        if isRaining {
            return "Don't forget your umbrella! ☔️"
        } else if temp >= 30 {
            return "Stay hydrated! Drink plenty of water 💧"
        } else if temp <= 5 {
            return "Bundle up! It's quite cold outside 🧥"
        }
        return nil
    }
    
    private func colorForUVLevel(_ level: UVIndexLevel) -> Color {
        switch level {
        case .low: return .green
        case .moderate: return .yellow
        case .high: return .orange
        case .veryHigh: return .red
        case .extreme: return .purple
        }
    }
    
    private func colorForAQLevel(_ level: AirQualityLevel) -> Color {
        switch level {
        case .good: return .green
        case .moderate: return .yellow
        case .unhealthyForSensitive: return .orange
        case .unhealthy: return .red
        case .veryUnhealthy: return .purple
        case .hazardous: return Color(.systemRed)
        }
    }
}

// MARK: - Warning Card Component
struct WarningCard: View {
    let text: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(text)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.6), lineWidth: 1)
                )
        )
    }
}

// MARK: - Weather Detail Card Component
struct WeatherDetailCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white.opacity(0.9))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
        )
    }
}

// MARK: - Health Index Card Component
struct HealthIndexCard: View {
    let icon: String
    let title: String
    let value: String
    let level: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(level)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Text(value)
                .font(.callout)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
        )
    }
}

// MARK: - Preview
#Preview("Sunny Weather with Health Data") {
    let sunnyWeather = WeatherResponse(
        current: CurrentWeather(
            time: "2024-01-01T12:00",
            temperature2m: 28.5,
            relativeHumidity2m: 65,
            apparentTemperature: 31.0,
            windSpeed10m: 10.5,
            windDirection10m: 180.0,
            weatherCode: 0,
            uvIndex: 8.5,
            pm25: 25.0,
            pm10: 35.0,
            carbonMonoxide: 200.0,
            nitrogenDioxide: 15.0,
            sulphurDioxide: 5.0,
            ozone: 80.0
        ),
        daily: DailyWeather(
            time: ["2024-01-01"],
            temperature2mMax: [32.0],
            temperature2mMin: [18.0],
            uvIndexMax: [9.2]
        ),
        hourly: HourlyWeather(
            time: ["2024-01-01T12:00"],
            temperature2m: [28.5]
        )
    )
    
    let sampleViewModel = WeatherViewModel()
    
    WeatherView(weather: sunnyWeather, viewModel: sampleViewModel)
        .background(WeatherCondition.clear.backgroundGradient)
}

#Preview("Poor Air Quality Weather") {
    let poorAirWeather = WeatherResponse(
        current: CurrentWeather(
            time: "2024-01-01T12:00",
            temperature2m: 22.0,
            relativeHumidity2m: 78,
            apparentTemperature: 24.0,
            windSpeed10m: 5.2,
            windDirection10m: 90.0,
            weatherCode: 3,
            uvIndex: 3.2,
            pm25: 65.0,
            pm10: 85.0,
            carbonMonoxide: 1200.0,
            nitrogenDioxide: 45.0,
            sulphurDioxide: 25.0,
            ozone: 120.0
        ),
        daily: DailyWeather(
            time: ["2024-01-01"],
            temperature2mMax: [25.0],
            temperature2mMin: [18.0],
            uvIndexMax: [4.5]
        ),
        hourly: HourlyWeather(
            time: ["2024-01-01T12:00"],
            temperature2m: [22.0]
        )
    )
    
    let sampleViewModel = WeatherViewModel()
    
    WeatherView(weather: poorAirWeather, viewModel: sampleViewModel)
        .background(WeatherCondition.cloudy.backgroundGradient)
}
