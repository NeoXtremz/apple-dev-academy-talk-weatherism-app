//
//  WeddingPlannerView.swift
//  WeatherismApp
//
//  Created by Wedding Planner Feature
//

import SwiftUI

struct WeddingPlannerView: View {
    @StateObject private var viewModel = WeddingPlannerViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Romantic gradient background
                romanticBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        headerSection
                        
                        // Date and Time Input Form
                        weddingDetailsForm
                        
                        // Analysis Results
                        if let weddingPlan = viewModel.weddingPlan {
                            analysisResults(for: weddingPlan)
                        }
                        
                        // Error State
                        if viewModel.hasError {
                            errorSection
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.pink.opacity(0.8))
                }
            }
        }
    }
    
    // MARK: - Background
    private var romanticBackground: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 1.0, green: 0.95, blue: 0.98), // Very soft pink
                Color(red: 0.98, green: 0.96, blue: 1.0), // Very soft lavender
                Color(red: 0.96, green: 0.98, blue: 1.0)  // Very soft blue
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 15) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.pink.opacity(0.8), .purple.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Wedding Weather Planner")
                .font(.largeTitle)
                .fontWeight(.light)
                .foregroundColor(.black.opacity(0.8))
            
            Text("Plan your perfect outdoor wedding day")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Wedding Details Form
    private var weddingDetailsForm: some View {
        VStack(spacing: 25) {
            VStack(alignment: .leading, spacing: 20) {
                // Venue Input
                VStack(alignment: .leading, spacing: 8) {
                    Label("Venue Location", systemImage: "location.fill")
                        .font(.headline)
                        .foregroundColor(.black.opacity(0.7))
                    
                    TextField("Enter city or venue location", text: $viewModel.venue)
                        .textFieldStyle(RomanticTextFieldStyle())
                }
                
                // Date Picker
                VStack(alignment: .leading, spacing: 8) {
                    Label("Wedding Date", systemImage: "calendar.circle.fill")
                        .font(.headline)
                        .foregroundColor(.black.opacity(0.7))
                    
                    DatePicker("", selection: $viewModel.weddingDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .tint(.pink.opacity(0.8))
                }
                
                // Time Picker
                VStack(alignment: .leading, spacing: 8) {
                    Label("Wedding Time", systemImage: "clock.circle.fill")
                        .font(.headline)
                        .foregroundColor(.black.opacity(0.7))
                    
                    DatePicker("", selection: $viewModel.weddingTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                        .tint(.pink.opacity(0.8))
                }
            }
            
            // Analyze Button
            Button(action: {
                Task {
                    await viewModel.analyzeWeddingWeather()
                }
            }) {
                HStack(spacing: 10) {
                    if viewModel.isAnalyzing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "sparkles")
                    }
                    
                    Text(viewModel.isAnalyzing ? "Analyzing Weather..." : "Check Wedding Weather")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [.pink.opacity(0.8), .purple.opacity(0.6)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(25)
                .shadow(color: .pink.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .disabled(!viewModel.canAnalyzeWeather)
            .opacity(viewModel.canAnalyzeWeather ? 1.0 : 0.6)
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.8))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - Analysis Results
    private func analysisResults(for weddingPlan: WeddingPlan) -> some View {
        VStack(spacing: 20) {
            if let forecast = weddingPlan.forecast {
                // Main Weather Assessment
                weatherAssessmentCard(for: forecast)
                
                // Alternative Dates (if weather isn't perfect)
                if !weddingPlan.alternativeDates.isEmpty && forecast.suitability != .perfect {
                    alternativeDatesSection(alternatives: weddingPlan.alternativeDates)
                }
            }
        }
    }
    
    // MARK: - Weather Assessment Card
    private func weatherAssessmentCard(for forecast: WeddingForecast) -> some View {
        VStack(spacing: 20) {
            // Weather Icon and Status
            VStack(spacing: 15) {
                Image(systemName: forecast.suitability.iconName)
                    .font(.system(size: 50))
                    .foregroundColor(iconColor(for: forecast.suitability))
                
                Text(forecast.suitability.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Text(forecast.suitability.message)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            
            // Weather Details
            weatherDetailsGrid(for: forecast.weather)
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(forecast.suitability.color.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(forecast.suitability.color.opacity(0.5), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Weather Details Grid
    private func weatherDetailsGrid(for weather: WeatherResponse) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
            WeatherDetailItem(
                icon: "thermometer",
                title: "Temperature",
                value: "\(Int(weather.current.temperature2m))°C",
                color: .orange.opacity(0.7)
            )
            
            WeatherDetailItem(
                icon: "wind",
                title: "Wind Speed",
                value: "\(Int(weather.current.windSpeed10m)) km/h",
                color: .blue.opacity(0.7)
            )
            
            WeatherDetailItem(
                icon: "humidity.fill",
                title: "Humidity",
                value: "\(weather.current.relativeHumidity2m)%",
                color: .cyan.opacity(0.7)
            )
            
            WeatherDetailItem(
                icon: "thermometer.snowflake",
                title: "Feels Like",
                value: "\(Int(weather.current.apparentTemperature))°C",
                color: .purple.opacity(0.7)
            )
        }
    }
    
    // MARK: - Alternative Dates Section
    private func alternativeDatesSection(alternatives: [WeddingForecast]) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Alternative Wedding Dates")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.black.opacity(0.8))
            
            Text("Here are some nearby dates with better weather conditions:")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            LazyVStack(spacing: 12) {
                ForEach(alternatives.prefix(5), id: \.date) { forecast in
                    AlternativeDateCard(forecast: forecast)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.white.opacity(0.6))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    // MARK: - Error Section
    private var errorSection: some View {
        VStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.red.opacity(0.7))
            
            Text("Unable to Check Weather")
                .font(.headline)
                .foregroundColor(.black.opacity(0.8))
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            Button("Try Again") {
                Task {
                    await viewModel.analyzeWeddingWeather()
                }
            }
            .buttonStyle(.bordered)
            .tint(.pink.opacity(0.8))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.red.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(.red.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Helper Methods
    private func iconColor(for suitability: WeddingSuitability) -> Color {
        switch suitability {
        case .perfect: return .pink.opacity(0.8)
        case .good: return .blue.opacity(0.8)
        case .risky: return .orange.opacity(0.8)
        case .unsuitable: return .red.opacity(0.8)
        }
    }
}

// MARK: - Supporting Views
struct RomanticTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 15)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.white.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(.pink.opacity(0.3), lineWidth: 1)
                    )
            )
    }
}

struct WeatherDetailItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.7))
        )
    }
}

struct AlternativeDateCard: View {
    let forecast: WeddingForecast
    
    var body: some View {
        HStack(spacing: 15) {
            // Date
            VStack(alignment: .leading, spacing: 2) {
                Text(forecast.date, style: .date)
                    .font(.headline)
                    .foregroundColor(.black.opacity(0.8))
                
                Text(dayOfWeek(from: forecast.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Weather Info
            HStack(spacing: 10) {
                Image(systemName: forecast.suitability.iconName)
                    .foregroundColor(iconColor(for: forecast.suitability))
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(forecast.weather.current.temperature2m))°C")
                        .font(.headline)
                        .foregroundColor(.black.opacity(0.8))
                    
                    Text(forecast.suitability.title.replacingOccurrences(of: " 💕", with: "").replacingOccurrences(of: " ✨", with: "").replacingOccurrences(of: " ⚠️", with: "").replacingOccurrences(of: " 🌧️", with: ""))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(forecast.suitability.color.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(forecast.suitability.color.opacity(0.4), lineWidth: 1)
                )
        )
    }
    
    private func dayOfWeek(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    private func iconColor(for suitability: WeddingSuitability) -> Color {
        switch suitability {
        case .perfect: return .pink.opacity(0.8)
        case .good: return .blue.opacity(0.8)
        case .risky: return .orange.opacity(0.8)
        case .unsuitable: return .red.opacity(0.8)
        }
    }
}

// MARK: - Preview
#Preview {
    WeddingPlannerView()
}