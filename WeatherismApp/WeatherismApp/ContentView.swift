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
                
                VStack(spacing: 20) {
                    // Search bar
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
                    .padding(.horizontal)
                    
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
                .padding()
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
                viewModel.searchWeather(for: cityName)
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
