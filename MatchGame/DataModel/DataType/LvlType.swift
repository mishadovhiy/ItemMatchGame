//
//  LvlType.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 27.11.2024.
//

import Foundation

extension LevelModel {
    enum LvlType:String, CaseIterable {
        case Meat, Bakery, DrinksAndFastFood, FruitsANDvegitables, fastFood, Drinks, Milk, MuilkANDcheese
        
        var allowedAssetNames:[String] {
            switch self {
            case .Meat:
                var values = ["pizza", "pasta", "cheese", "eggs", "garlic", "milk1", "milk", "milk2", "paper"]
                values.insert(contentsOf: Array(1...3).compactMap({"meat\($0)"}), at:0)
                return values
            case .Bakery:
                var values = ["bakeryDonate"]
                values.append(contentsOf: Array(1...9).compactMap({"bakerySweet\($0)"}))
                values.append(contentsOf: Array(1...2).compactMap({"bakeryBread\($0)"}))
                return values
            case .DrinksAndFastFood:
                return ["cheaps", "pasta", "pizza", "cheese", "buttleBlack", "buttleBlue", "buttleBlue2", "buttleBrown", "bakerySweet1", "bakerySweet2", "bakerySweet3", "bakerySweet4", "buttleGreen"]
            case .FruitsANDvegitables:
                var values:[String] = ["orange"]
                values.append(contentsOf: Array(1...15).compactMap({"fruits\($0)"}))
                return values
            case .fastFood:
                return ["cheaps", "pasta", "pizza", "cheese", "popcorn", "milk", "buttleBrown", "buttleGreen", "bakerySweet1", "bakerySweet2", "bakerySweet3", "bakerySweet4", "eggs"]
            case .Drinks:
                return ["buttleBlack", "buttleBlue", "buttleBlue2", "buttleBrown", "bakerySweet1", "bakerySweet2", "bakerySweet3", "bakerySweet4", "buttleGreen", "milk1", "milk", "milk2"]
            case .Milk:
                return ["garlic", "milk1", "milk", "milk2", "eggs", "paper", "buttleGreen", "bakerySweet4", "bakerySweet5", "bakerySweet6", "buttleBlue2", "milk", "cheaps", "pasta"]
            case .MuilkANDcheese:
                return ["garlic", "milk1", "milk", "milk2", "eggs", "paper", "eggs", "bakerySweet6", "bakerySweet7", "bakerySweet8", "cheese", "cheaps", "buttleGreen", "buttleBlue2", "bakerySweet3"]
            }
        }
        
        var title:String {
            return rawValue.replacingOccurrences(of: "AND", with: " & ").replacingOccurrences(of: "[A-Z]", with: " $0", options: .regularExpression).capitalized
        }
        
        init(_ lvl:Int) {
            let all = LvlType.allCases
            let last = Int(String("\(lvl)".last ?? .init(""))) ?? 0
            if all.count - 1 >= last {
                self = all[last]
            } else {
                self = all.last ?? .Bakery
            }
            
        }
    }
    
    static func name(_ forLVL:Int) -> LvlType {
        .init(forLVL)
    }
}
