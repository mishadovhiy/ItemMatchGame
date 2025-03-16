//
//  SuccessNode.swift
//  Swipster
//
//  Created by Misha Dovhiy on 17.01.2023.
//

import SpriteKit

class SuccessNode:SKSpriteNode {
    
    var type:SCSType
    init(type:SCSType) {
        self.type = type
        let color:UIColor = [.red, .green, .blue].randomElement() ?? .red
        super.init(texture: .init(image: .init(named: type.imgName)!), color: color, size: type.size)
        self.color = color
        super.color = color
        
        if type != .Oval {
            let val:CGFloat = [2, 4, 3, 1].randomElement() ?? 0
            self.zRotation = .pi / val
        }
    }
    var removeCalled = false
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func remove() {
        if !removeCalled {
            removeCalled = true
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                self.removeAllChildren()
                self.removeAllActions()
                self.removeFromParent()
                SuccessSKScene.shared?.addSCSNodes()
            })
            
        }
    }

}


extension SuccessNode {
    enum SCSType {
        case Oval, YellowLine, RedLine, greenTriggles
        
        var imgName:String {
            switch self {
                
            case .Oval:
                let names = ["blueOval", "greenOval", "purpureOval"].randomElement() ?? ""
                return "Game/" + names
            case .YellowLine:
                let lines = ["yellowLine2", "yellowLine1"].randomElement() ?? ""
                return "Game/" + lines
            case .RedLine:
                return "Game/redLine"
            case .greenTriggles:
                let int = Int.random(in: 1..<22)
                return "Game/WheelSCStriggles/Path\(int)"
            }
        }
        
        var size: CGSize {
            switch self {
                
            case .Oval:
                let ovals = [15, 25, 40, 60, 40, 30, 10, 30, 35, 30].randomElement() ?? 0
                return .init(width: ovals, height: ovals)
            case .YellowLine:
                let vals = [(80, 80), (60, 60), (40, 40), (20, 20)].randomElement() ?? (0,0)
                return .init(width: vals.0, height: vals.1)
            case .RedLine:
                let vals = [(30, 30), (40, 40), (60, 60), (20, 62)].randomElement() ?? (0,0)
                return .init(width: vals.0, height: vals.1)
            case .greenTriggles:
                let vals = [(80, 80), (60, 60), (40, 40), (20, 20)].randomElement() ?? (0,0)
                return .init(width: vals.0, height: vals.1)
            }
        }
    }
}
