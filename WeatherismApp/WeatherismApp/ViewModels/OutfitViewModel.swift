//
//  OutfitViewModel.swift
//  WeatherismApp
//
//  Created by Regina Celine Adiwinata on 06/08/25.
//

import Foundation

@MainActor
class OutfitViewModel: ObservableObject {
    @Published var outfits: [OutfitItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: OutfitServiceProtocol

    init(service: OutfitServiceProtocol) {
        self.service = service
    }

    func loadOutfits(for condition: WeatherCondition) {
        let keyword = outfitKeyword(for: condition)
        Task {
            await fetch(keyword: keyword)
        }
    }
    
    func outfitKeyword(for condition: WeatherCondition) -> String {
        switch condition {
        case .clear: return "summer outfit"
        case .partlyCloudy, .cloudy: return "casual autumn outfit"
        case .foggy: return "cozy hoodie outfit"
        case .drizzle, .rainy: return "raincoat streetwear"
        case .snowy: return "winter coat fashion"
        case .stormy: return "windbreaker outfit"
        }
    }


    private func fetch(keyword: String) async {
        isLoading = true
        errorMessage = nil
        do {
            outfits = try await service.fetchOutfits(for: keyword)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
