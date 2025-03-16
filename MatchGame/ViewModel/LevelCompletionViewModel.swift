//
//  LevelCompletionViewModel.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 06.12.2024.
//

import Foundation

struct LevelCompletionViewModel {
    
    var spinPresenting = true
    var apiDataIndex:Int?
    var woneIndex:Int?
    var disabledSpin = false

    var spinCount = 0
    var spinsCointMax:Int = 10
    let spinMaxValueCount = 6
    let rotationsSortedWheel:[CGFloat] = [-30, 30, 90, 150, -150, -90]
    let rotationsSortedData:[CGFloat] = [-30, -90, 30, -150, 90, 150]
    var wheelRotateCalled = false
    var selectedRow:Int = 0
    
    var wheelData:[String] {
        ["-5", "5", "15", "40", "10", "5"]
    }

    var weelRotationSortered:CGFloat {
        return rotationsSortedWheel[selectedRow]
    }
    let weelDataIndexes:[CGFloat:Int] = [
        -30:0, -90:1, 30:2, -150:3, 90:4, 150:5
    ]
    
    var rotationToDataIndex:Int {
        return weelDataIndexes[weelRotationSortered] ?? 0
    }
    
    mutating func spinPressedValid() -> Bool {
        if !disabledSpin {
            
            spinsCointMax = Int.random(in: 20..<60)//Int.random(in: 8..<16)
            spinCount = 0
            
            woneIndex = nil
            apiDataIndex = nil
            return true
        }
        return false
    }
}
