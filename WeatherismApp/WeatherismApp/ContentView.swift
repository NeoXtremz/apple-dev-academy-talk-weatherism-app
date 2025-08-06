//
//  ContentView.swift
//  WeatherismApp
//
//  Created by Agustinus Pongoh on 05/08/25.
//

import SwiftUI

// MARK: - Content View
struct ContentView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var cityName = "London"
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dynamic background gradient based on weather condition
                backgroundGradient
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 1.0), value: viewModel.currentWeatherCondition)
                
                VStack(spacing: 0) { // Set spacing to 0 to have suggestions appear right below the search bar
                    
                    // Search Bar and Suggestions
                    VStack {
                        HStack {
                            TextField("Enter city name", text: $cityName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onSubmit {
                                    viewModel.searchWeather(for: cityName)
                                }
                                .submitLabel(.search)
                            
                            Button("Search") {
                                viewModel.searchWeather(for: cityName)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(viewModel.isLoading || cityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        
                        // --- SUGGESTIONS LIST ---
                        if !viewModel.citySuggestions.isEmpty {
                            List(viewModel.citySuggestions, id: \.name) { suggestion in
                                Button(action: {
                                    // Set city name, clear suggestions, and search
                                    self.cityName = "\(suggestion.name)"
                                    viewModel.searchWeather(for: self.cityName)
                                }) {
                                    Text("\(suggestion.name), \(suggestion.country)")
                                }
                            }
                            .listStyle(.plain)
                            .frame(height: 150) // Limit the height of the suggestions list
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20) // Add padding to separate from content below
                    
                    // Main Content
                    if viewModel.isLoading {
                        ProgressView("Loading weather...")
                            .foregroundColor(.white)
                    } else if viewModel.hasError, let errorMessage = viewModel.errorMessage {
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 60))
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    } else if viewModel.hasWeatherData, let weather = viewModel.weatherData {
                        WeatherView(weather: weather, viewModel: viewModel)
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "cloud.sun")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                            Text("Welcome to Weatherism")
                                .font(.title)
                                .foregroundColor(.white)
                            Text("Enter a city name to get started")
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Weatherism")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.refreshWeather()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.white)
                    }
                    .disabled(viewModel.isLoading || !viewModel.hasWeatherData)
                }
            }
            .onAppear {
                if viewModel.weatherData == nil { // Only search on first appear
                    viewModel.searchWeather(for: cityName)
                }
            }
            .onChange(of: cityName) { newValue in
                // Update suggestions whenever the text field changes
                viewModel.updateCitySuggestions(for: newValue)
            }
        }
    }
    
    // MARK: - Computed Properties
    private var backgroundGradient: LinearGradient {
        if viewModel.hasWeatherData {
            return viewModel.currentWeatherCondition.backgroundGradient
        } else {
            // Default gradient when no weather data
            return LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
