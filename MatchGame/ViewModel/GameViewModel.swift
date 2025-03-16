//
//  GameViewModel.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 17.11.2024.
//

import Foundation

struct GameViewModel {
    var timerValue:CGFloat = 0
    var level:LevelModel.Level = .init(number: 0, difficulty: .easy) 
    var itemSize:CGFloat {
        30//self.shavedData.numSections >= 5 ? (self.shavedData.numSections >= 8 ? 40 : 50) : 58
    }
    var initialTimerValue:CGFloat {
        return CGFloat(self.allDataCount * (LevelModel.levelCount.rawValue - Int(CGFloat(level.number / 10))))
    }
    
    var maxLastMovedTime = 5000
    mutating func coinsMultiplierInitialTimer() {
        if cointsMultiplier <= 1 {
            cointsMultiplier = 1
        }
        cointsMultiplier += 1
        print(cointsMultiplier, " regfwdwregtrb")
        lastMovedTimerAmount = maxLastMovedTime
    }
    var lastMovedTimerAmount:Int? = nil
    var freezeTimerAmount: Int = 0
    var cointsMultiplier = 1
    let heightMultiplier:CGFloat = 1.5
    var multiplierTimerStarted = false
    private var emptyShavesPercent:Int {
        let levelHigh = level.number <= (LevelModel.levelCount.rawValue / 2)
        return switch level.difficulty {
        case .easy:
            25//levelHigh ? 20 : 15
        case .medium:
            22//levelHigh ? 15 : 10
        case .hard:
            levelHigh ? 15 : 19
        }
    }
    var shavedData: ShavesData {
        let levelHigh = level.number <= (LevelModel.levelCount.rawValue / 2)
        let hidden:Int
        let sections:Int
        let rows:Int
        switch self.level.difficulty {
        case .easy:
            hidden = levelHigh ? 3 : 2
            sections = ((!levelHigh ? 2 : 3) + level.levelDivider)
            rows = 9
        case .medium:
            hidden = levelHigh ? 4 : 3
            sections = (!levelHigh ? 3 : 4) + level.levelDivider
            rows = 9
        case .hard:
            hidden = levelHigh ? 6 : 5
            sections = (!levelHigh ? 4 : 5) + level.levelDivider
            rows = 9
        }
        
        return .init(numSections: sections, numRows: rows, hiddenShaves: hidden + Int(self.level.number / 10))
    }
    var gameLost = false
    var gameCompleted = false
    var allDataCount:Int {
        let maxTypes = DropData.DropType.normalCases(self.level).count * shavedData.itemsInRow
        return ((shavedData.numSections * shavedData.numRows) * shavedData.hiddenShaves) - maxTypes
    }
    var hasMoves = true
    var openedAll = false
    var initialUserScore:Int = 0
    var droppedCount = 0 {
        didSet {
            if openedAll && !hasMoves {
                print(gameCompleted)
                gameCompleted = true
            }
        }
    }
    var shaves:[DropData.DropType] {
        let range = 0..<(shavedData.numSections * shavedData.numRows)
        let hiddenMax = 1
        print("hiddenMaxhiddenMax: ", hiddenMax)
        let hiddensAt = (0..<hiddenMax).compactMap { _ in
            Int.random(in: range)
        }
        return range.compactMap {
            if hiddensAt.contains($0) {
                print("isnonee")
                return DropData.DropType.none
            } else {
                return .randomNormal(level)
            }
            
        }
    }
    
    
}

extension GameViewModel {
    typealias DropData = LevelModel.DropData
    
    struct ShavesData {
        var numSections = 5
        var numRows = 6
        let itemsInRow = 3
        var rowSections:Int {
            numRows / itemsInRow
        }
        var hiddenShaves = 3
    }
}
