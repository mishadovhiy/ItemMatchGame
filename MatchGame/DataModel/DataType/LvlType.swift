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
                var values = ["cheaps", "pasta", "pizza", "popcorn", "pizza"]
                values.append(contentsOf: (0..<26).compactMap({"bakeryUnhealthy\($0)"}))
                return values.shuffled()
            case .Bakery:
                return (0..<23).compactMap({"vegs\($0)"}).shuffled()
            case .DrinksAndFastFood:
                var values = Array(1...15).compactMap({"fruits\($0)"})
             //   values.append(contentsOf: (0..<13).compactMap({"fruit\($0)"}))
                return values.shuffled()
            case .FruitsANDvegitables:
                var buttle = ["buttleBlack", "buttleBlue", "buttleBlue2", "buttleBrown", "buttleGreen", "milk1", "milk", "milk2"]
                buttle.append(contentsOf: (0..<11).compactMap({"water\($0)"}))
                return buttle.shuffled()
            case .fastFood:
                var values = ["bakeryDonate"]
                values.append(contentsOf: Array(1...9).compactMap({"bakerySweet\($0)"}))
                values.append(contentsOf: Array(1...2).compactMap({"bakeryBread\($0)"}))
                return values.shuffled()
            case .Drinks://replace
                return ["buttleBlack", "buttleBlue", "buttleBlue2", "buttleBrown", "bakerySweet1", "bakerySweet2", "bakerySweet3", "bakerySweet4", "buttleGreen", "milk1", "milk", "milk2"]
            case .Milk://replace
                return ["garlic", "milk1", "milk", "milk2", "eggs", "paper", "buttleGreen", "bakerySweet4", "bakerySweet5", "bakerySweet6", "buttleBlue2", "milk", "cheaps", "pasta"]
            case .MuilkANDcheese://replace
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
