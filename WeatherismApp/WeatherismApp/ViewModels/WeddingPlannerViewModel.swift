//
//  WeddingPlannerViewModel.swift
//  WeatherismApp
//
//  Created by Wedding Planner Feature
//

import Foundation
import SwiftUI

@MainActor
class WeddingPlannerViewModel: ObservableObject {
    @Published var weddingDate = Date()
    @Published var weddingTime = Date()
    @Published var venue = ""
    @Published var weddingPlan: WeddingPlan?
    @Published var isAnalyzing = false
    @Published var errorMessage: String?
    @Published var hasError = false
    
    private let weatherService: WeatherService
    
    init(weatherService: WeatherService = WeatherService()) {
        self.weatherService = weatherService
    }
    
    var formattedWeddingDateTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        
        return "\(dateFormatter.string(from: weddingDate)) at \(timeFormatter.string(from: weddingTime))"
    }
    
    var canAnalyzeWeather: Bool {
        !venue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isAnalyzing
    }
    
    func analyzeWeddingWeather() async {
        guard canAnalyzeWeather else { return }
        
        isAnalyzing = true
        hasError = false
        errorMessage = nil
        
        do {
            // Combine date and time
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: weddingDate)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: weddingTime)
            
            var combinedComponents = DateComponents()
            combinedComponents.year = dateComponents.year
            combinedComponents.month = dateComponents.month
            combinedComponents.day = dateComponents.day
            combinedComponents.hour = timeComponents.hour
            combinedComponents.minute = timeComponents.minute
            
            let selectedDateTime = calendar.date(from: combinedComponents) ?? weddingDate
            
            // Fetch weather for selected date
            let forecast = try await weatherService.fetchWeddingForecast(for: venue, date: selectedDateTime)
            
            // Fetch alternative dates if weather isn't perfect
            var alternatives: [WeddingForecast] = []
            if forecast.suitability != .perfect {
                alternatives = try await weatherService.fetchAlternativeWeddingDates(for: venue, around: selectedDateTime)
            }
            
            weddingPlan = WeddingPlan(
                selectedDate: selectedDateTime,
                venue: venue,
                forecast: forecast,
                alternativeDates: alternatives
            )
            
        } catch {
            hasError = true
            if let networkError = error as? NetworkError {
                errorMessage = networkError.localizedDescription
            } else {
                errorMessage = "Unable to fetch weather data. Please try again."
            }
        }
        
        isAnalyzing = false
    }
    
    func clearAnalysis() {
        weddingPlan = nil
        hasError = false
        errorMessage = nil
    }
}