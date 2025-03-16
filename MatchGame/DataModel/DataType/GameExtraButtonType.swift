//
//  GameExtraButtonType.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 27.11.2024.
//

import Foundation

enum GameExtraButtonType:String, CaseIterable {
    case hammer
    case randomize
    case stopTimer
    case paint
    
    var itemDesription:MessageContent {
        .init(title: itemTitle, desription: """
Play more to get more coins
""")
    }
    
    private var itemTitle:String {
        return rawValue.replacingOccurrences(of: "[A-Z]", with: " $0", options: .regularExpression).capitalized
    }
    
    var price:Int {
       return switch self {
        case .hammer:
            30
        case .randomize:
            10
       case .stopTimer:
            30
        case .paint:
            50
        }
    }
}
