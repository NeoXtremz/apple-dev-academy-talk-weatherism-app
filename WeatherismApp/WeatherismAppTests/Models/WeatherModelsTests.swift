//
//  WeatherModelsTests.swift
//  WeatherismAppTests
//
//  Created by Agustinus Pongoh on 05/08/25.
//

import XCTest
@testable import WeatherismApp

final class WeatherModelsTests: XCTestCase {
    
    // MARK: - JSON Parsing Tests
    func testWeatherResponseDecoding() {
        // Given
        let jsonString = """
        {
            "current": {
                "time": "2024-01-01T12:00",
                "temperature_2m": 22.5,
                "relative_humidity_2m": 65,
                "apparent_temperature": 24.0,
                "wind_speed_10m": 10.5,
                "wind_direction_10m": 180.0,
                "weather_code": 0
            },
            "daily": {
                "time": ["2024-01-01", "2024-01-02"],
                "temperature_2m_max": [25.0, 26.0],
                "temperature_2m_min": [18.0, 19.0]
            },
            "hourly": {
                "time": ["2024-01-01T12:00", "2024-01-01T13:00"],
                "temperature_2m": [22.5, 23.0]
            }
        }
        """
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            XCTFail("Failed to create JSON data")
            return
        }
        
        // When
        do {
            let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: jsonData)
            
            // Then
            XCTAssertEqual(weatherResponse.current.time, "2024-01-01T12:00")
            XCTAssertEqual(weatherResponse.current.temperature2m, 22.5)
            XCTAssertEqual(weatherResponse.current.relativeHumidity2m, 65)
            XCTAssertEqual(weatherResponse.current.apparentTemperature, 24.0)
            XCTAssertEqual(weatherResponse.current.windSpeed10m, 10.5)
            XCTAssertEqual(weatherResponse.current.windDirection10m, 180.0)
            XCTAssertEqual(weatherResponse.current.weatherCode, 0)
            
            XCTAssertEqual(weatherResponse.daily.time.count, 2)
            XCTAssertEqual(weatherResponse.daily.temperature2mMax[0], 25.0)
            XCTAssertEqual(weatherResponse.daily.temperature2mMin[0], 18.0)
            
            XCTAssertEqual(weatherResponse.hourly.time.count, 2)
            XCTAssertEqual(weatherResponse.hourly.temperature2m[0], 22.5)
            
        } catch {
            XCTFail("Failed to decode WeatherResponse: \(error)")
        }
    }
    
    func testGeocodingResponseDecoding() {
        // Given
        let jsonString = """
        {
            "results": [
                {
                    "name": "London",
                    "latitude": 51.5074,
                    "longitude": -0.1278,
                    "country": "United Kingdom",
                    "country_code": "GB"
                }
            ]
        }
        """
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            XCTFail("Failed to create JSON data")
            return
        }
        
        // When
        do {
            let geocodingResponse = try JSONDecoder().decode(GeocodingResponse.self, from: jsonData)
            
            // Then
            XCTAssertNotNil(geocodingResponse.results)
            XCTAssertEqual(geocodingResponse.results?.count, 1)
            
            let result = geocodingResponse.results?.first
            XCTAssertEqual(result?.name, "London")
            XCTAssertEqual(result?.latitude, 51.5074)
            XCTAssertEqual(result?.longitude, -0.1278)
            XCTAssertEqual(result?.country, "United Kingdom")
            XCTAssertEqual(result?.countryCode, "GB")
            
        } catch {
            XCTFail("Failed to decode GeocodingResponse: \(error)")
        }
    }
    
    func testGeocodingResponseWithEmptyResults() {
        // Given
        let jsonString = """
        {
            "results": []
        }
        """
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            XCTFail("Failed to create JSON data")
            return
        }
        
        // When
        do {
            let geocodingResponse = try JSONDecoder().decode(GeocodingResponse.self, from: jsonData)
            
            // Then
            XCTAssertNotNil(geocodingResponse.results)
            XCTAssertEqual(geocodingResponse.results?.count, 0)
            
        } catch {
            XCTFail("Failed to decode GeocodingResponse with empty results: \(error)")
        }
    }
    
    func testGeocodingResponseWithNullResults() {
        // Given
        let jsonString = """
        {
            "results": null
        }
        """
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            XCTFail("Failed to create JSON data")
            return
        }
        
        // When
        do {
            let geocodingResponse = try JSONDecoder().decode(GeocodingResponse.self, from: jsonData)
            
            // Then
            XCTAssertNil(geocodingResponse.results)
            
        } catch {
            XCTFail("Failed to decode GeocodingResponse with null results: \(error)")
        }
    }
    
    // MARK: - Model Property Tests
    func testCurrentWeatherCodingKeys() {
        // Test that the CodingKeys enum maps correctly
        XCTAssertEqual(CurrentWeather.CodingKeys.temperature2m.rawValue, "temperature_2m")
        XCTAssertEqual(CurrentWeather.CodingKeys.relativeHumidity2m.rawValue, "relative_humidity_2m")
        XCTAssertEqual(CurrentWeather.CodingKeys.apparentTemperature.rawValue, "apparent_temperature")
        XCTAssertEqual(CurrentWeather.CodingKeys.windSpeed10m.rawValue, "wind_speed_10m")
        XCTAssertEqual(CurrentWeather.CodingKeys.windDirection10m.rawValue, "wind_direction_10m")
        XCTAssertEqual(CurrentWeather.CodingKeys.weatherCode.rawValue, "weather_code")
    }
    
    func testDailyWeatherCodingKeys() {
        // Test that the CodingKeys enum maps correctly
        XCTAssertEqual(DailyWeather.CodingKeys.temperature2mMax.rawValue, "temperature_2m_max")
        XCTAssertEqual(DailyWeather.CodingKeys.temperature2mMin.rawValue, "temperature_2m_min")
    }
    
    func testHourlyWeatherCodingKeys() {
        // Test that the CodingKeys enum maps correctly
        XCTAssertEqual(HourlyWeather.CodingKeys.temperature2m.rawValue, "temperature_2m")
    }
    
    func testGeocodingResultCodingKeys() {
        // Test that the CodingKeys enum maps correctly
        XCTAssertEqual(GeocodingResult.CodingKeys.countryCode.rawValue, "country_code")
    }
    
    // MARK: - NetworkError Tests
    func testNetworkErrorDescriptions() {
        XCTAssertEqual(NetworkError.invalidURL.errorDescription, "Invalid URL")
        XCTAssertEqual(NetworkError.noData.errorDescription, "No data received")
        XCTAssertEqual(NetworkError.cityNotFound.errorDescription, "City not found. Please check the spelling and try again.")
    }
    
    func testNetworkErrorEquality() {
        XCTAssertEqual(NetworkError.invalidURL, NetworkError.invalidURL)
        XCTAssertEqual(NetworkError.noData, NetworkError.noData)
        XCTAssertEqual(NetworkError.cityNotFound, NetworkError.cityNotFound)
        
        XCTAssertNotEqual(NetworkError.invalidURL, NetworkError.noData)
        XCTAssertNotEqual(NetworkError.noData, NetworkError.cityNotFound)
        XCTAssertNotEqual(NetworkError.invalidURL, NetworkError.cityNotFound)
    }
    
    // MARK: - Edge Cases
    func testWeatherResponseWithMissingOptionalData() {
        // Given - JSON with minimal required fields
        let jsonString = """
        {
            "current": {
                "time": "2024-01-01T12:00",
                "temperature_2m": 22.5,
                "relative_humidity_2m": 65,
                "apparent_temperature": 24.0,
                "wind_speed_10m": 10.5,
                "wind_direction_10m": 180.0,
                "weather_code": 0
            },
            "daily": {
                "time": ["2024-01-01"],
                "temperature_2m_max": [25.0],
                "temperature_2m_min": [18.0]
            },
            "hourly": {
                "time": ["2024-01-01T12:00"],
                "temperature_2m": [22.5]
            }
        }
        """
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            XCTFail("Failed to create JSON data")
            return
        }
        
        // When
        do {
            let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: jsonData)
            
            // Then
            XCTAssertNotNil(weatherResponse.current)
            XCTAssertNotNil(weatherResponse.daily)
            XCTAssertNotNil(weatherResponse.hourly)
            
        } catch {
            XCTFail("Failed to decode minimal WeatherResponse: \(error)")
        }
    }
    
    func testInvalidJSON() {
        // Given
        let invalidJsonString = """
        {
            "current": {
                "time": "2024-01-01T12:00",
                "temperature_2m": "not_a_number"
            }
        }
        """
        
        guard let jsonData = invalidJsonString.data(using: .utf8) else {
            XCTFail("Failed to create JSON data")
            return
        }
        
        // When & Then
        XCTAssertThrowsError(try JSONDecoder().decode(WeatherResponse.self, from: jsonData)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }
    
    // MARK: - Weather Condition Tests
    func testWeatherConditionDisplayNames() {
        XCTAssertEqual(WeatherCondition.clear.displayName, "Clear")
        XCTAssertEqual(WeatherCondition.partlyCloudy.displayName, "Partly Cloudy")
        XCTAssertEqual(WeatherCondition.cloudy.displayName, "Cloudy")
        XCTAssertEqual(WeatherCondition.foggy.displayName, "Foggy")
        XCTAssertEqual(WeatherCondition.drizzle.displayName, "Drizzle")
        XCTAssertEqual(WeatherCondition.rainy.displayName, "Rainy")
        XCTAssertEqual(WeatherCondition.snowy.displayName, "Snowy")
        XCTAssertEqual(WeatherCondition.stormy.displayName, "Stormy")
    }
    
    func testWeatherConditionBackgroundGradients() {
        // Test that all weather conditions have background gradients
        for condition in WeatherCondition.allCases {
            let gradient = condition.backgroundGradient
            XCTAssertNotNil(gradient)
            // Verify gradient has colors
//            XCTAssertFalse(gradient.gradient.stops.isEmpty)
        }
    }
    
    func testWeatherConditionCaseIterable() {
        // Test that all cases are included in allCases
        let expectedCount = 8 // clear, partlyCloudy, cloudy, foggy, drizzle, rainy, snowy, stormy
        XCTAssertEqual(WeatherCondition.allCases.count, expectedCount)
        
        // Test specific cases exist
        XCTAssertTrue(WeatherCondition.allCases.contains(.clear))
        XCTAssertTrue(WeatherCondition.allCases.contains(.rainy))
        XCTAssertTrue(WeatherCondition.allCases.contains(.snowy))
        XCTAssertTrue(WeatherCondition.allCases.contains(.stormy))
    }
}
