//
//  MessageViewModel.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 27.11.2024.
//

import Foundation

struct MessageViewModel {
    struct ScreenData {
        var screenTitle:String
        var primaryButton:ButtonData? = nil
      //  var secondaryButton:ButtonData? = nil
        let tableData:[TableData]
        struct TableData {
            let sectionTitle:String
            var cells:[CollectionData]
            
            struct CollectionData {
                
                var title:String
                var image:String = ""
                var type:CollectionDataType?
                var toVC:MessageVC.ContentType? = nil
            }
            enum CollectionDataType {
                case button(ButtonColorType)
                case float(FloatType)
                case message(MessageContent)
                
                var content:MessageContent? {
                    return switch self {
                    case .message(let value): value
                    default: nil
                    }
                }
                var floatData:FloatType? {
                    return switch self {
                    case .float(let float): float
                    default: nil
                    }
                }
                
                struct FloatType {
                    var defaultValue:Int
                    // 0..<100
                    var progress:Int
                    var didChanged:(Int)->()
                }
                struct ButtonColorType {
                    var type:ButtonColor
                    
                    var didPress:()->()
                    
                    enum ButtonColor:CaseIterable {
                        case red, green, blue
                        
                        static var randomElement:ButtonColor {
                            return ButtonColor.allCases.randomElement() ?? .blue
                        }
                    }
                }
                
            }
        }
        
    }
    
    enum ContentType {
        case settings(_ okPressed:()->())
        case sound(_ okPressed:()->())
        case custom(ScreenData)
        
        func screenData(db:DB.DataBase, okPressed:@escaping ()->()) -> ScreenData {
            switch self {
            case .settings(let ok):
                let cells: [ScreenData.TableData.CollectionData] = [
                    .init(title: "Sound", image: "sound", toVC: .sound(ok))
                ]
                //  cells.append(contentsOf: additionalData)
                return .init(screenTitle: "Menu", tableData: [
                    .init(sectionTitle: "", cells: cells)
                ])
            case .sound(let ok):
                return .init(screenTitle: "Sound", tableData: [
                    .init(sectionTitle: "", cells: DB.DataBase.SoundParameters.Sound.allCases.compactMap({ sound in
                        let valume = db.sound.valuems[sound] ?? sound.default
                        return .init(title: sound.rawValue.capitalized, type: .float(.init(defaultValue: Int(sound.default * 100), progress: Int(valume * 100), didChanged: { newValue in
                            let new = CGFloat(newValue) / 100
                            DispatchQueue(label: "db", qos: .userInitiated).async {
                                DB.db.sound.valuems.updateValue(new, forKey: sound)
                                DispatchQueue.main.async {
                                    okPressed()
                                    ok()
                                }
                            }
                        })))
                    }))
                ])
            case .custom(let screenData):
                return screenData
            }
        }
    }
}
