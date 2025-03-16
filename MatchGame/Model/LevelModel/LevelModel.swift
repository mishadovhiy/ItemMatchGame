//
//  LevelModel.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 18.11.2024.
//

import Foundation

enum LevelModel:Int {
    case levelCount = 50
    case minimumUnlockedLvl = 3
    static let dividerNumber:Int = 10
    struct Level:Codable {
        var number:Int
        var difficulty:Difficulty
        
        var levelDivider:Int {
            (number / LevelModel.dividerNumber) + 1
        }
    }
    
    enum Difficulty:String, Codable, CaseIterable {
        case easy, medium, hard
        var number:Int {
            return switch self {
            case .easy:
                 1
            case .medium:
                2
            case .hard:
                3
            }
        }
    }
}

