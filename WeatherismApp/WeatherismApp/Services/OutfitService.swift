//
//  OutfitService.swift
//  WeatherismApp
//
//  Created by Regina Celine Adiwinata on 06/08/25.
//

import Foundation

enum OutfitError: LocalizedError {
    case invalidURL
    case noData
    case decodeError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noData: return "No data received"
        case .decodeError: return "Failed to decode data"
        }
    }
}

protocol OutfitServiceProtocol {
    func fetchOutfits(for keyword: String) async throws -> [OutfitItem]
}

class UnsplashService: OutfitServiceProtocol {
    private let accessKey: String

    init(accessKey: String) {
        self.accessKey = accessKey
    }

    func fetchOutfits(for keyword: String) async throws -> [OutfitItem] {
        guard let query = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.unsplash.com/search/photos?query=\(query)&per_page=10")
        else {
            throw OutfitError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        let root = try JSONDecoder().decode(UnsplashSearchResponse.self, from: data)

        return root.results.map {
            OutfitItem(
                id: $0.id,
                title: $0.description ?? keyword,
                imageUrl: $0.urls.small,
                link: $0.urls.regular
            )
        }
    }
}
