//
//  RemoteDataService.swift
//  Neotris
//
//  Created by Rishi Singh on 12/04/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class RemoteDataService {
    // To add a new remote data type later (e.g. app announcements), you'd add a URL constant, a cache key, a published var, a private fetchXxx() async method, and a call to it inside fetchAllData() — the generic fetch and cache machinery handles the rest.
    // MARK: - Remote Data

    var builtInThemes: [BuiltInTheme]

    // MARK: - State

    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - URLs

    private let builtInThemesURL = URL(string: "https://raw.githubusercontent.com/rishi-singh26/Neotris/refs/heads/database/database/themes/content.json")!

    // MARK: - Cache Keys

    private static let builtInThemesCacheKey = "cachedBuiltInThemes"

    // MARK: - Init

    init() {
        builtInThemes = Self.loadCached([BuiltInTheme].self, forKey: Self.builtInThemesCacheKey) ?? BuiltInTheme.all
    }

    // MARK: - Fetch All

    /// Fetches all remote data. Call once on app launch from terminated state.
    func fetchAllData() async {
        isLoading = true
        errorMessage = nil
        await fetchBuiltInThemes()
        isLoading = false
    }

    // MARK: - Generic Async Fetcher

    private func fetch<T: Decodable>(from url: URL, as type: T.Type) async throws -> T {
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(T.self, from: data)
    }

    // MARK: - Built-in Themes

    private func fetchBuiltInThemes() async {
        do {
            let response = try await fetch(from: builtInThemesURL, as: BuiltInThemeResponse.self)
            builtInThemes = response.themes
            saveToCache(response.themes, forKey: Self.builtInThemesCacheKey)
        } catch {
            print("RemoteDataService: failed to fetch built-in themes — \(error)")
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Generic Cache Helpers

    private static func loadCached<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private func saveToCache<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}

// MARK: - Response Types

private struct BuiltInThemeResponse: Decodable {
    let themes: [BuiltInTheme]
}
