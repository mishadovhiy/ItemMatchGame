//
//  CALayer.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 17.11.2024.
//

import QuartzCore

extension CALayer {
    func zoom(value:CGFloat) {
        self.transform = CATransform3DMakeScale(value, value, 1)
    }
    
    
    enum MoveDirection {
        case top
        case left
    }
    
    func move(_ direction:MoveDirection, value:CGFloat) {
        switch direction {
        case .top:
            self.transform = CATransform3DTranslate(CATransform3DIdentity, 0, value, 0)
        case .left:
            self.transform = CATransform3DTranslate(CATransform3DIdentity, value, 0, 0)
        }
    }
    
    func radius(_ value:CGFloat? = nil, at:RadiusAt) {
        self.cornerRadius = value ?? (self.frame.height / 2)
        self.maskedCorners = at.masks
    }

    enum RadiusAt {
        case top
        case btn
        case left
        case right
        
        var masks: CACornerMask {
            switch self {
            case .top:
                return [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            case .btn:
                return [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            case .left:
                return [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            case .right:
                return [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
            }
        }
    }
}
