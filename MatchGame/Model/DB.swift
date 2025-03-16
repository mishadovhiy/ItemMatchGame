//
//  DB.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 18.11.2024.
//

import Foundation

struct DB {
    static private let dbName:String = "DataBase8"
    static var dbBackup:DataBase? {
        get {
            let value = DataBase.configure(UserDefaults.standard.data(forKey: dbName + "holder")) ?? .init()
            return value
        }
        set {
            if let data = newValue.decode {
                UserDefaults.standard.setValue(data, forKey: dbName + "holder")
            } else {
                UserDefaults.standard.removeObject(forKey: dbName + "holder")
            }
        }
    }
    static var db:DataBase {
        get {
            if let dbHolder {
                return dbHolder
            }
#if DEBUG
            if Thread.isMainThread {
                print("threadError\n", #file, "\n", #line)
            }
#endif
            let value = DataBase.configure(UserDefaults.standard.data(forKey: dbName)) ?? .init()
            dbHolder = value
            return value
        }
        set {
            if Thread.isMainThread {
                DispatchQueue(label: "db", qos: .userInitiated).async {
                    updateDB(newValue)
                }
            } else {
                updateDB(newValue)
            }
        }
    }
    
    static private func updateDB(_ newValue:DataBase) {
        dbHolder = newValue
        
        if let data = newValue.decode {
            UserDefaults.standard.set(data, forKey: dbName)
         //   UserDefaults.standard.setValue(data, forKey: dbName)
        } else {
            UserDefaults.standard.removeObject(forKey: dbName)
        }
    }
    
    static var dbHolder:DataBase?
    
}

extension DB {
    struct DataBase:Codable {
        var profile:Profile = .init()
        var sound:SoundParameters = .init()
    }
}

extension DB.DataBase {
    struct Profile:Codable {
        var score:Int = 250
        var levels:[Int:[LevelModel.Difficulty]] = [:]
        
        func canBuy(_ price:Int) -> Bool {
            if score >= price {
                return true
            } else {
                return false
            }
        }
        
        mutating func refillBalance(_ amount:Int) -> Bool {
            if canBuy(amount) {
                self.score += amount
                return true
            } else {
                return false
            }
        }
    }
    struct SoundParameters:Codable {
        private var _valuems:[Sound:CGFloat]?
        var valuems:[Sound:CGFloat] {
            get {
                return prepareValuems(_valuems)
            }
            set {
                _valuems = prepareValuems(newValue)
            }
        }
        
        private func prepareValuems(_ value: [Sound:CGFloat]?) -> [Sound:CGFloat] {
            var newValue = value ?? [:]
            Sound.allCases.forEach {
                newValue.updateValue(newValue[$0] ?? $0.default, forKey: $0)
            }
            return newValue
        }
        
        enum Sound:String, Codable, CaseIterable {
            case background, menu, click
            var `default`:CGFloat {
                return switch self {
                case .background:0.4
                case .menu:0.9
                case .click:1
                }
            }
        }
    }
    
}

