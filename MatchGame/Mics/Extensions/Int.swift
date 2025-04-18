//
//  Int.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 26.11.2024.
//

import Foundation

extension Int {
    func closestMultipleOfThree() -> Int {
        let remainder = self % 3
        
        if remainder == 0 {
            return self
        }
        
        return self - remainder
    }
    
    var timeString:String {
        let minute:Double = Double(Double(self) / Double(60))
        let second = Int((minute - Double(Int(minute))) * 60)
        var stringMin = "\(Int(minute))"
        if minute <= 9 {
            stringMin = "0\(Int(minute))"
        }
        var stringSec = "\(second)"
        if second <= 9 {
            stringSec = "0\(second)"
        }
        return "\(stringMin):\(stringSec)"
    }
    
}
extension String {
    var addSpaceBeforeCapitalizedLetters: String {
        let regex = try? NSRegularExpression(pattern: "(?<=\\w)(?=[A-Z])", options: [])
        let result = regex?.stringByReplacingMatches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count), withTemplate: " $0")
        return result ?? self
    }
}
