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
}
