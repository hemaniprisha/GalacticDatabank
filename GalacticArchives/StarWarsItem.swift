// Models/StarWarsItem.swift
import Foundation

enum ItemType: String, Codable, CaseIterable {
    case people = "people"
    case planets = "planets"
    case films = "films"
    case species = "species"
    case vehicles = "vehicles"
    case starships = "starships"
    
    var displayName: String {
        switch self {
        case .people: return "Characters"
        case .planets: return "Planets"
        case .films: return "Films"
        case .species: return "Species"
        case .vehicles: return "Vehicles"
        case .starships: return "Starships"
        }
    }
    
    var iconName: String {
        switch self {
        case .people: return "person.fill"
        case .planets: return "globe"
        case .films: return "film"
        case .species: return "pawprint.fill"
        case .vehicles: return "car"
        case .starships: return "airplane"
        }
    }
}

struct StarWarsItem: Codable, Identifiable, Equatable {
    let id = UUID()
    let name: String
    let title: String?
    let description: String?
    let openingCrawl: String?
    let director: String?
    let producer: String?
    let releaseDate: String?
    let height: String?
    let mass: String?
    let hairColor: String?
    let skinColor: String?
    let eyeColor: String?
    let birthYear: String?
    let gender: String?
    let homeworld: String?
    let films: [String]?
    let species: [String]?
    let vehicles: [String]?
    let starships: [String]?
    let created: String
    let edited: String
    let url: String
    var type: ItemType = .people
    var imageUrl: String?

    var additionalInfo: [String: String] {
        var info: [String: String] = [:]
        if let height = height, !height.isEmpty { info["Height"] = height }
        if let mass = mass, !mass.isEmpty { info["Mass"] = mass }
        if let hairColor = hairColor, !hairColor.isEmpty { info["Hair Color"] = hairColor }
        if let skinColor = skinColor, !skinColor.isEmpty { info["Skin Color"] = skinColor }
        if let eyeColor = eyeColor, !eyeColor.isEmpty { info["Eye Color"] = eyeColor }
        if let birthYear = birthYear, !birthYear.isEmpty { info["Birth Year"] = birthYear }
        if let gender = gender, !gender.isEmpty { info["Gender"] = gender }
        if let homeworld = homeworld, !homeworld.isEmpty { info["Homeworld"] = homeworld }
        if let releaseDate = releaseDate, !releaseDate.isEmpty { info["Release Date"] = releaseDate }
        if let director = director, !director.isEmpty { info["Director"] = director }
        if let producer = producer, !producer.isEmpty { info["Producer"] = producer }
        return info
    }
    
    var displayName: String {
        return name.isEmpty ? (title ?? "Unknown") : name
    }
    
    var displayDescription: String {
        if let description = description, !description.isEmpty {
            return description
        } else if let openingCrawl = openingCrawl, !openingCrawl.isEmpty {
            return openingCrawl
        } else {
            return "No description available"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name, title, description, director, producer, height, mass, gender, created, edited, url
        case openingCrawl = "opening_crawl"
        case releaseDate = "release_date"
        case hairColor = "hair_color"
        case skinColor = "skin_color"
        case eyeColor = "eye_color"
        case birthYear = "birth_year"
        case homeworld, films, species, vehicles, starships
    }
    
    static func == (lhs: StarWarsItem, rhs: StarWarsItem) -> Bool {
        return lhs.id == rhs.id
    }
}

struct StarWarsResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [StarWarsItem]
}
