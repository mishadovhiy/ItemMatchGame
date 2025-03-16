//
//  DropData.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 26.11.2024.
//

import Foundation
import UIKit

extension LevelModel {
    struct DropData:Codable {
        var type:DropType = .none
        var id:UUID = .init()
        
        enum DropType:String, Codable, CaseIterable {
            // case ovalRed, triggle, square, none
            case ovalRed = "cheaps"
            case ovalPink = "eggs"
            case ovalBlue = "garlic"
            case ovalYellow = "milk1"
            case triggleRed = "milk2"
            case trigglePink = "orange"
            case triggleBlue = "pasta"
            case triggleYellow = "pizza"
            case bakerySweet1, bakerySweet2, bakerySweet3, bakerySweet4, bakerySweet5, bakerySweet6, bakerySweet7, bakerySweet8, bakerySweet9
            case bakeryBread1, bakeryBread2
            case bakeryDonate
            //new
            case buttleBlack
            case buttleBlue
            case buttleBlue2
            case buttleBrown
            case buttleGreen
            
            case fruits1, fruits2, fruits3, fruits4, fruits5, fruits6, fruits7, fruits8, fruits9, fruits10, fruits11, fruits12, fruits13, fruits14, fruits15
            
            case cheese
            case milk
            case paper
            case popcorn
            
            case none
            
            static var `default`:Self {
                .ovalRed
            }

            var image:UIImage {
                if rawValue.contains("square") {
                    return .rectengle
                } else if rawValue.contains("oval") {
                    return .oval
                } else if rawValue.contains("triggle") {
                    return .triaggle
                } else if rawValue.contains("star") {
                    return .star
                } else {
                    return UIImage(named: self.rawValue)!
                }
            }
            var color:UIColor {
                //                return switch self {
                //                case .ovalRed:
                //                        .red
                //                case .triggle:
                //                        .green
                //                case .square:
                //                        .blue
                //                case .none:
                //                        .gray
                //                }
                if rawValue.contains("Red") {
                    return .red
                } else if rawValue.contains("Pink") {
                    return .systemPink
                } else if rawValue.contains("Blue") {
                    return .blue
                } else if rawValue.contains("Yellow") {
                    return .yellow
                } else {
                    return .darkContainer.withAlphaComponent(0.8)
                }
                
            }
            static func normalCases(_ lvl:LevelModel.Level) -> [DropType] {
                let lvType = LevelModel.LvlType(lvl.number)
                let switchNumber = lvl.levelDivider
                var allowed = lvType.allowedAssetNames
                let switchPercent = CGFloat(switchNumber) / CGFloat((LevelModel.levelCount.rawValue / LevelModel.dividerNumber) + 1) * CGFloat(allowed.count)
                allowed = allowed.prefix(
                    Int(switchPercent)).compactMap({
                    $0
                })
                print(allowed.count, " fredwsa")
                print(switchNumber, " rgvfcedsx ", switchPercent)
                var array:[DropData.DropType] = DropData.DropType.allCases.filter({ type in
                    allowed.contains(where: {type.rawValue.contains($0)})})
                //= DragImageView.DropData.DropType.allCases
                array.removeAll(where: {$0 == .none})
                return array
            }
            static func randomNormal(_ lvl:LevelModel.Level) -> DropType {
                return normalCases(lvl).randomElement()!
            }
        }
    }
}

extension [LevelModel.DropData.DropType]? {
    var isEquel:Bool {
        guard let self = self,
              let _ = self.first
        else {
            return false
        }
        return self.allSatisfy({$0.rawValue == self.first?.rawValue})
    }
}
extension [LevelModel.DropData.DropType] {
    var isEquel:Bool {
        guard let _ = self.first
        else {
            return false
        }
        return self.allSatisfy({$0.rawValue == self.first?.rawValue})
    }
}
