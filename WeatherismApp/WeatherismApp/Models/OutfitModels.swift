//
//  OutfitModels.swift
//  WeatherismApp
//
//  Created by Regina Celine Adiwinata on 06/08/25.
//

import Foundation

struct UnsplashSearchResponse: Codable {
    let results: [UnsplashPhoto]
}

struct UnsplashPhoto: Codable, Identifiable {
    let id: String
    let description: String?
    let urls: UnsplashPhotoURLs
}

struct UnsplashPhotoURLs: Codable {
    let small: String
    let regular: String
}

struct OutfitItem: Identifiable {
    let id: String
    let title: String
    let imageUrl: String
    let link: String
}
