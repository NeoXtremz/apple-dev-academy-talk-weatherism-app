import SwiftUI

// MARK: - Weather View
struct WeatherView: View {
    let weather: WeatherResponse
    let viewModel: WeatherViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Location
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                Text(viewModel.locationDisplayName)
                    .font(.title2)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
            }
            
            // Weather icon and description
            VStack(spacing: 10) {
                Image(systemName: viewModel.weatherIconName(for: weather.current.weatherCode))
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                
                Text(viewModel.weatherDescription(for: weather.current.weatherCode))
                    .font(.title3)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
            }
            
            // Temperature
            VStack(spacing: 5) {
                Text("\(Int(weather.current.temperature2m))°C")
                    .font(.system(size: 72, weight: .thin))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.8), radius: 3, x: 0, y: 2)
                
                Text("Feels like \(Int(weather.current.apparentTemperature))°C")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.95))
                    .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
            }
            
            // Weather details
            HStack(spacing: 20) {
                WeatherDetailView(
                    icon: "thermometer.low",
                    title: "Min",
                    value: "\(Int(weather.daily.temperature2mMin.first ?? 0))°C"
                )
                
                WeatherDetailView(
                    icon: "thermometer.high",
                    title: "Max",
                    value: "\(Int(weather.daily.temperature2mMax.first ?? 0))°C"
                )
                
                WeatherDetailView(
                    icon: "humidity",
                    title: "Humidity",
                    value: "\(weather.current.relativeHumidity2m)%"
                )
                
                WeatherDetailView(
                    icon: "wind",
                    title: "Wind",
                    value: "\(String(format: "%.1f", weather.current.windSpeed10m)) km/h"
                )
            }
            .padding()
            .background(Color.black.opacity(0.3))
            .cornerRadius(15)
        }
        .padding()
    }
}

// MARK: - Weather Detail View
struct WeatherDetailView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.6), radius: 1, x: 0, y: 1)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.6), radius: 1, x: 0, y: 1)
        }
    }
}
