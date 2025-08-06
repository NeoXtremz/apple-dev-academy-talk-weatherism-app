//
//  ContentView.swift
//  WeatherismApp
//
//  Created by Agustinus Pongoh on 05/08/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var cityName = "London"
    
    var body: some View {
        ZStack {
            // Background gradient
            currentBackgroundGradient
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // Title
                    Text("Weatherism")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    // Search Bar
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
                    
                    // Content
                    if viewModel.isLoading {
                        ProgressView("Loading weather...")
                            .foregroundColor(.white)
                            .padding(.top, 40)
                        
                    } else if viewModel.hasError, let errorMessage = viewModel.errorMessage {
                        VStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                        
                    } else if viewModel.hasWeatherData, let weather = viewModel.weatherData {
                        WeatherView(weather: weather, viewModel: viewModel)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                    } else {
                        // Welcome Screen
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
                        .padding(.top, 40)
                    }
                }
                .padding(.bottom, 50) // ruang di bawah untuk scroll
            }
        }
        .onAppear {
            viewModel.searchWeather(for: cityName)
        }
    }
    
    // Background gradient
    private var currentBackgroundGradient: LinearGradient {
        if viewModel.hasWeatherData {
            return viewModel.currentWeatherCondition.backgroundGradient
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

#Preview {
    ContentView()
}
