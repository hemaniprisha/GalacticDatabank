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
    let name: String?
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

    // Species-specific
    let classification: String?
    let designation: String?
    let averageHeight: String?
    let skinColors: String?
    let averageLifespan: String?
    let language: String?
    let speciesHairColors: String?
    let speciesEyeColors: String?

    // Vehicle / starship specific
    let model: String?
    let manufacturer: String?
    let costInCredits: String?
    let length: String?
    let maxAtmospheringSpeed: String?
    let crew: String?
    let passengers: String?
    let cargoCapacity: String?
    let consumables: String?
    let vehicleClass: String?

    // Starship-only fields
    let hyperdriveRating: String?
    let MGLT: String?
    let starshipClass: String?

    // Planet-specific (for planets category)
    let rotationPeriod: String?
    let orbitalPeriod: String?
    let diameter: String?
    let climate: String?
    let gravity: String?
    let terrain: String?
    let surfaceWater: String?
    let population: String?

    // Film-specific
    let episodeId: Int?
    var type: ItemType = .people
    var imageUrl: String?

    var additionalInfo: [String: String] {
        var info: [String: String] = [:]

        switch type {
        case .people:
            if let height = height, !height.isEmpty { info["Height"] = "\(height) cm" }
            if let mass = mass, !mass.isEmpty { info["Mass"] = "\(mass) kg" }
            if let hairColor = hairColor, !hairColor.isEmpty { info["Hair Color"] = hairColor }
            if let skinColor = skinColor, !skinColor.isEmpty { info["Skin Color"] = skinColor }
            if let eyeColor = eyeColor, !eyeColor.isEmpty { info["Eye Color"] = eyeColor }
            if let birthYear = birthYear, !birthYear.isEmpty { info["Birth Year"] = birthYear }
            if let gender = gender, !gender.isEmpty { info["Gender"] = gender }

        case .species:
            if let classification = classification, !classification.isEmpty { info["Classification"] = classification }
            if let designation = designation, !designation.isEmpty { info["Designation"] = designation }
            if let averageHeight = averageHeight, !averageHeight.isEmpty { info["Average Height"] = "\(averageHeight) cm" }
            if let skinColors = skinColors, !skinColors.isEmpty { info["Skin Colors"] = skinColors }
            if let hairColors = speciesHairColors, !hairColors.isEmpty { info["Hair Colors"] = hairColors }
            if let eyeColors = speciesEyeColors, !eyeColors.isEmpty { info["Eye Colors"] = eyeColors }
            if let averageLifespan = averageLifespan, !averageLifespan.isEmpty { info["Average Lifespan"] = averageLifespan }
            if let language = language, !language.isEmpty { info["Language"] = language }

        case .vehicles:
            if let model = model, !model.isEmpty { info["Model"] = model }
            if let manufacturer = manufacturer, !manufacturer.isEmpty { info["Manufacturer"] = manufacturer }
            if let vehicleClass = vehicleClass, !vehicleClass.isEmpty { info["Class"] = vehicleClass }
            if let length = length, !length.isEmpty { info["Length"] = length }
            if let maxSpeed = maxAtmospheringSpeed, !maxSpeed.isEmpty { info["Max Speed"] = maxSpeed }
            if let crew = crew, !crew.isEmpty { info["Crew"] = crew }
            if let passengers = passengers, !passengers.isEmpty { info["Passengers"] = passengers }
            if let cargoCapacity = cargoCapacity, !cargoCapacity.isEmpty { info["Cargo Capacity"] = cargoCapacity }
            if let consumables = consumables, !consumables.isEmpty { info["Consumables"] = consumables }

        case .starships:
            if let model = model, !model.isEmpty { info["Model"] = model }
            if let manufacturer = manufacturer, !manufacturer.isEmpty { info["Manufacturer"] = manufacturer }
            if let starshipClass = starshipClass, !starshipClass.isEmpty { info["Class"] = starshipClass }
            if let hyperdriveRating = hyperdriveRating, !hyperdriveRating.isEmpty { info["Hyperdrive Rating"] = hyperdriveRating }
            if let MGLT = MGLT, !MGLT.isEmpty { info["MGLT"] = MGLT }
            if let length = length, !length.isEmpty { info["Length"] = length }
            if let crew = crew, !crew.isEmpty { info["Crew"] = crew }
            if let passengers = passengers, !passengers.isEmpty { info["Passengers"] = passengers }
            if let cargoCapacity = cargoCapacity, !cargoCapacity.isEmpty { info["Cargo Capacity"] = cargoCapacity }
            if let consumables = consumables, !consumables.isEmpty { info["Consumables"] = consumables }

        case .planets:
            if let rotationPeriod = rotationPeriod, !rotationPeriod.isEmpty { info["Rotation Period"] = rotationPeriod }
            if let orbitalPeriod = orbitalPeriod, !orbitalPeriod.isEmpty { info["Orbital Period"] = orbitalPeriod }
            if let diameter = diameter, !diameter.isEmpty { info["Diameter"] = diameter }
            if let climate = climate, !climate.isEmpty { info["Climate"] = climate }
            if let gravity = gravity, !gravity.isEmpty { info["Gravity"] = gravity }
            if let terrain = terrain, !terrain.isEmpty { info["Terrain"] = terrain }
            if let surfaceWater = surfaceWater, !surfaceWater.isEmpty { info["Surface Water"] = surfaceWater }
            if let population = population, !population.isEmpty { info["Population"] = population }

        case .films:
            if let episodeId = episodeId { info["Episode"] = String(episodeId) }
            if let director = director, !director.isEmpty { info["Director"] = director }
            if let producer = producer, !producer.isEmpty { info["Producer"] = producer }
            if let releaseDate = releaseDate, !releaseDate.isEmpty { info["Release Date"] = releaseDate }
        }

        return info
    }
    
    var displayName: String {
        return name?.isEmpty == false ? name! : (title ?? "Unknown")
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
        case classification, designation, language
        case averageHeight = "average_height"
        case skinColors = "skin_colors"
        case averageLifespan = "average_lifespan"
        case speciesHairColors = "hair_colors"
        case speciesEyeColors = "eye_colors"
        case model, manufacturer, length
        case costInCredits = "cost_in_credits"
        case maxAtmospheringSpeed = "max_atmosphering_speed"
        case crew, passengers
        case cargoCapacity = "cargo_capacity"
        case consumables
        case vehicleClass = "vehicle_class"
        case hyperdriveRating = "hyperdrive_rating"
        case MGLT
        case starshipClass = "starship_class"
        case rotationPeriod = "rotation_period"
        case orbitalPeriod = "orbital_period"
        case diameter, climate, gravity, terrain
        case surfaceWater = "surface_water"
        case population
        case episodeId = "episode_id"
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
