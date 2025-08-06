//
//  WeatherViewModel.swift
//  WeatherismApp
//
//  Created by Agustinus Pongoh on 05/08/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Weather View Model
@MainActor
class WeatherViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var weatherData: WeatherResponse?
    @Published var locationDisplayName: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var citySuggestions: [GeocodingResult] = []

    // MARK: - Computed Properties
    var hasError: Bool {
        errorMessage != nil
    }
    
    var hasWeatherData: Bool {
        weatherData != nil
    }
    
    var currentWeatherCondition: WeatherCondition {
        guard let code = weatherData?.current.weatherCode else { return .clear }
        return weatherCondition(for: code)
    }
    
    // MARK: - Private Properties
    private let weatherService: WeatherServiceProtocol
    private var lastSearchedCity: String?
    private var searchCancellable: AnyCancellable?
    private let searchSubject = PassthroughSubject<String, Never>()

    // MARK: - Initializer
    init(weatherService: WeatherServiceProtocol = WeatherService()) {
        self.weatherService = weatherService
        
        // Debounce logic for search suggestions
        searchCancellable = searchSubject
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.fetchCitySuggestions(for: query)
            }
    }
    
    // MARK: - Public Methods
    
    /// Triggers the process to update city suggestions based on the query.
    func updateCitySuggestions(for query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self.citySuggestions = []
            return
        }
        searchSubject.send(query)
    }
    
    /// Fetches weather for a given city name.
    func searchWeather(for city: String) {
        let trimmedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedCity.isEmpty else { return }
        
        lastSearchedCity = trimmedCity
        isLoading = true
        errorMessage = nil
        citySuggestions = [] // Clear suggestions when a search is initiated
        
        Task {
            do {
                let (weatherResponse, location) = try await weatherService.fetchWeather(for: trimmedCity)
                self.weatherData = weatherResponse
                self.locationDisplayName = "\(location.name), \(location.countryCode)"
            } catch let networkError as NetworkError {
                self.errorMessage = networkError.localizedDescription
            } catch {
                self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    /// Refreshes the weather for the last searched city.
    func refreshWeather() {
        guard let city = lastSearchedCity else { return }
        searchWeather(for: city)
    }

    /// Provides a user-friendly description for a given weather code.
    func weatherDescription(for code: Int) -> String {
        return weatherCondition(for: code).displayName
    }
    
    /// Provides an SFSymbol icon name for a given weather code.
    func weatherIconName(for code: Int) -> String {
        switch weatherCondition(for: code) {
        case .clear: return "sun.max.fill"
        case .partlyCloudy: return "cloud.sun.fill"
        case .cloudy: return "cloud.fill"
        case .foggy: return "cloud.fog.fill"
        case .drizzle: return "cloud.drizzle.fill"
        case .rainy: return "cloud.rain.fill"
        case .snowy: return "cloud.snow.fill"
        case .stormy: return "cloud.bolt.rain.fill"
        }
    }
    
    // MARK: - Private Methods

    /// Fetches a list of city suggestions from the weather service.
    private func fetchCitySuggestions(for query: String) {
        Task {
            // We only show suggestions if the query is not empty.
            guard !query.isEmpty else {
                self.citySuggestions = []
                return
            }
            
            do {
                // Assuming the service can fetch suggestions. This needs to be added to WeatherService.
                if let service = weatherService as? WeatherService {
                    self.citySuggestions = try await service.fetchCitySuggestions(for: query)
                }
            } catch {
                // Silently fail or log the error, as we don't want to show an error for suggestions.
                print("Failed to fetch city suggestions: \(error.localizedDescription)")
                self.citySuggestions = []
            }
        }
    }
    
    /// Maps a WMO weather code to a `WeatherCondition`.
    private func weatherCondition(for code: Int) -> WeatherCondition {
        switch code {
        case 0: return .clear
        case 1, 2, 3: return .partlyCloudy
        case 45, 48: return .foggy
        case 51, 53, 55, 56, 57: return .drizzle
        case 61, 63, 65, 66, 67, 80, 81, 82: return .rainy
        case 71, 73, 75, 77, 85, 86: return .snowy
        case 95, 96, 99: return .stormy
        default: return .cloudy
        }
    }
}
