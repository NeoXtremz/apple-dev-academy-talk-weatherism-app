# Tech Spec: Dynamic Weather UI with Weather API Integration

- **Author**: Thingkilia
- **Engineering Lead**: Thingkilia
- **Product Specs**: –
- **Important Documents**: –
- **JIRA Epic**: –
- **Figma**: –
- **Figma Prototype**: –
- **BE Tech Specs**: Uses Weather API (Open-Meteo or similar, endpoint: `current_weather`, `daily`, `hourly`)
- **Content Specs**: No localization required (English text only at this time)
- **Instrumentation Specs**: No event tracking
- **QA Test Suite**: –
- **PICs**:
  - PIC FE (iOS, SwiftUI): Thingkilia
  - PIC BE: –
  - PIC PM: –
  - PIC Designer: –
  - PIC QA: –

---

## Project Overview
This app displays real-time weather information based on the user’s entered location. The background color gradient and weather icon change dynamically according to weather conditions retrieved from an API.

---

## Requirements

### Functional Requirements
- User can enter a city name in the text field.
- Pressing the **Search** button fetches weather data from an API based on the entered city name.
- Display location, weather icon, description, temperature, apparent temperature, min & max temperature, humidity, and wind speed.
- Background gradient changes according to weather condition (`clear`, `rainy`, `snowy`, etc.).

### Non-Functional Requirements
- Text must remain readable on all background conditions.
- API response time < 2 seconds on normal connection.
- Support iOS 15+.

---

## High-Level Diagram
```
[User Input City] → [Weather API Call] → [Parse JSON] → [Update ViewModel] → [Update SwiftUI View with Data & Gradient]
```

---

## Low-Level Diagram
```
WeatherView.swift
  ↳ WeatherViewModel.swift
      ↳ fetchWeatherData(cityName)
          ↳ WeatherAPIService.swift
              ↳ Call Weather API (URLSession)
                  ↳ Decode response into WeatherResponse
                      ↳ Update Published Properties
```

---

## Code Structure & Implementation Details
```swift
struct WeatherView: View {
    let weather: WeatherResponse
    let viewModel: WeatherViewModel
    
    var body: some View {
        VStack {
            // Location
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.white)
                Text(viewModel.locationDisplayName)
                    .foregroundColor(.white)
            }
            
            // Icon + description
            VStack {
                Image(systemName: viewModel.weatherIconName(for: weather.current.weatherCode))
                    .foregroundColor(.white)
                Text(viewModel.weatherDescription(for: weather.current.weatherCode))
                    .foregroundColor(.white)
            }
            
            // Temperature
            VStack {
                Text("\(Int(weather.current.temperature2m))°C")
                    .foregroundColor(.white)
                Text("Feels like \(Int(weather.current.apparentTemperature))°C")
                    .foregroundColor(.white.opacity(0.9))
            }
            
            // Detail cards
            HStack {
                WeatherDetailView(icon: "thermometer.low", title: "Min", value: "\(Int(weather.daily.temperature2mMin.first ?? 0))°C")
                WeatherDetailView(icon: "thermometer.high", title: "Max", value: "\(Int(weather.daily.temperature2mMax.first ?? 0))°C")
                WeatherDetailView(icon: "humidity", title: "Humidity", value: "\(weather.current.relativeHumidity2m)%")
                WeatherDetailView(icon: "wind", title: "Wind", value: "\(String(format: "%.1f", weather.current.windSpeed10m)) km/h")
            }
            .padding()
            .background(Color.black.opacity(0.3))
            .cornerRadius(15)
        }
        .padding()
    }
}
```

---

## Operational Excellence
- **Monitoring**: None
- **Error Handling**: Handles API failures (e.g., city not found) with a fallback state

---

## Backward Compatibility / Rollback Plan
- No impact on older versions as this is a standalone app
- Rollback by reverting to previous commit

---

## Rollout Plan
- Full rollout due to small scope and low risk

---

## Out of Scope
- Language localization
- Automatic GPS integration
- 7-day forecast

---

## Demo
- **Screenshot**: ![Weatherism Screenshot](attach_screenshot_here)
- **Screen Recording**: –

---

## Steps to Use This Feature
1. Open Weatherism app
2. Enter city name in the text field
3. Tap **Search**
4. App will display weather data with matching background gradient

---

## Discussions and Alignments
**Q:** How to ensure text readability on bright background gradients?  
**A:** Add a semi-transparent dark overlay behind the text.
