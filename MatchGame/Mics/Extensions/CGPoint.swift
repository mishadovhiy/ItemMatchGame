//
//  CGPoint.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 18.11.2024.
//

import Foundation

extension CGPoint {
    static func + (lh:CGPoint, rh:CGPoint) -> CGPoint {
        return .init(x: lh.x + rh.x, y: lh.y + rh.y)
    }
}
