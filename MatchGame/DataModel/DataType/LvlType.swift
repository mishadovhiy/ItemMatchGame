//
//  LvlType.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 27.11.2024.
//

import Foundation
import UIKit

extension LevelModel {
    enum LvlType:String, CaseIterable {
        case cannedFood, vegitables, fruits, drinks, bakery, fastFood, kitchen, sweets
        
        var allowedAssetNames:[String] {
            switch self {
            case .cannedFood:
                return (1..<12).compactMap({"canned\($0)"}).shuffled()
            case .vegitables:
                return (1..<10).compactMap({"vegs\($0)"}).shuffled()
            case .fruits:
                var values = Array(14...21).compactMap({"fruit\($0)"})
                values.append(contentsOf: (0..<13).compactMap({"ftuit\($0)"}))
                return values.shuffled()
            case .drinks:
                return (1..<12).compactMap({"water\($0)"}).shuffled()
            case .bakery:
                return (14..<26).compactMap({"bakeryUnhealthy\($0)"})
            case .fastFood:
                return Array(1...17).compactMap({"fastfood\($0)"})
            case .kitchen:
                return (1..<11).compactMap({"kitchen\($0)"}).shuffled()

            case .sweets:
                return (1..<13).compactMap({"bakeryUnhealthy\($0)"}).shuffled()
            }
        }
        
        var title:String {
            return rawValue.replacingOccurrences(of: "AND", with: " & ").replacingOccurrences(of: "[A-Z]", with: " $0", options: .regularExpression).addSpaceBeforeCapitalizedLetters.capitalized
        }
        
        init(_ lvl:Int) {
            let all = LvlType.allCases
            let last = Int(String("\(lvl)".last ?? .init(""))) ?? 0
            if all.count - 1 >= last {
                self = all[last]
            } else {
                self = all.last ?? .vegitables
            }
            
        }
        private var imageNumber:Int {
            switch self {
            case .cannedFood:
                1
            case .vegitables:
                2
            case .fruits:
                3
            case .drinks:
                4
            case .bakery:
                5
            case .fastFood:
                6
            case .kitchen:
                7
            case .sweets:
                8
            }
        }
        var primaryLevelSelectionImage:UIImage {
            if let image = UIImage(named: "level\(imageNumber)Horizontal") {
                return image
            } else {
                return UIImage(named: "level2Horizontal")!
            }
        }
    }
    
    static func name(_ forLVL:Int) -> LvlType {
        .init(forLVL)
    }
}
