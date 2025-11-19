// Network/NetworkManager.swift
import UIKit

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noData: return "No data received"
        case .decodingError: return "Failed to decode response"
        case .serverError(let message): return "Server error: \(message)"
        }
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://swapi.dev/api"
    private let imageCache = NSCache<NSString, UIImage>()
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    private init() {}
    
    func fetchItems(type: ItemType, page: Int = 1) async throws -> [StarWarsItem] {
        let endpoint = "\(baseURL)/\(type.rawValue)/?page=\(page)"
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid response")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("HTTP Error: \(httpResponse.statusCode)")
        }
        
        do {
            let response = try jsonDecoder.decode(StarWarsResponse.self, from: data)
            var items = response.results
            for index in items.indices {
                items[index].type = type
            }
            return items
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func fetchItems(
        type: ItemType,
        page: Int = 1,
        completion: @escaping (Result<[StarWarsItem], Error>) -> Void
    ) {
        Task {
            do {
                let items = try await fetchItems(type: type, page: page)
                completion(.success(items))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func searchItems(query: String) async throws -> [StarWarsItem] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let endpoint = "\(baseURL)/people/?search=\(encodedQuery)"
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try jsonDecoder.decode(StarWarsResponse.self, from: data)
        var items = response.results
        for index in items.indices {
            items[index].type = .people
        }
        return items
    }
    
    func searchItems(
        query: String,
        completion: @escaping (Result<[StarWarsItem], Error>) -> Void
    ) {
        Task {
            do {
                let items = try await searchItems(query: query)
                completion(.success(items))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func loadImage(from urlString: String) async throws -> UIImage {
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            return cachedImage
        }
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let image = UIImage(data: data) else {
            throw NetworkError.decodingError
        }
        
        imageCache.setObject(image, forKey: urlString as NSString)
        return image
    }
}
