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
                return (0..<13).compactMap({"bakeryUnhealthy\($0)"}).shuffled()
            case .Bakery:
                return (0..<10).compactMap({"vegs\($0)"}).shuffled()
            case .DrinksAndFastFood:
                var values = Array(14...21).compactMap({"fruit\($0)"})
                values.append(contentsOf: (0..<13).compactMap({"ftuit\($0)"}))
                return values.shuffled()
            case .FruitsANDvegitables:
                return (0..<12).compactMap({"water\($0)"}).shuffled()
            case .fastFood:
                return (14..<26).compactMap({"bakeryUnhealthy\($0)"})
            case .Drinks:
                return Array(1...17).compactMap({"fastfood\($0)"})
            case .Milk://replace
                return (11..<23).compactMap({"vegs\($0)"}).shuffled()

            case .MuilkANDcheese://replace
                return (13..<26).compactMap({"water\($0)"}).shuffled()
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
