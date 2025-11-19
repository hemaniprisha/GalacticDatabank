// Theme/Theme.swift
import UIKit

enum Theme {
    // Accent colors inspired by lightsabers / factions
    static func accentColor(for type: ItemType) -> UIColor {
        switch type {
        case .people:
            return UIColor.systemBlue // Jedi blue
        case .planets:
            return UIColor.systemGreen // nature/planets
        case .films:
            return UIColor.systemRed // Sith / conflict
        case .species:
            return UIColor.systemTeal
        case .vehicles:
            return UIColor.systemOrange
        case .starships:
            return UIColor.systemPurple
        }
    }
}
