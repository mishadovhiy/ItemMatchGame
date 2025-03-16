//
//  SuccessSKScene.swift
//  Swipster
//
//  Created by Misha Dovhiy on 17.01.2023.
//

import SpriteKit
import GameplayKit
import UIKit

class SuccessSKScene: SKScene {

    var scsType:ObjectsType = .coloredConfety
    
    static var shared:SuccessSKScene?
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        SuccessSKScene.shared = self
        physicsWorld.contactDelegate = self
        physicsWorld.speed = 0.23
        setupLvl()
    }

    static func create(view:UIView, type:ObjectsType = .coloredConfety) {
        if let newView = view as! SKView? {
            if let scene = SKScene(fileNamed: "SuccessSKScene") as? SuccessSKScene {
                scene.scaleMode = .aspectFill
                scene.scsType = type
                scene.backgroundColor = .clear
                newView.presentScene(scene)
            }
            newView.ignoresSiblingOrder = true
            newView.showsFPS = true
            newView.showsNodeCount = false
        }
    }
    var mapNode: SKTileMapNode?
    func setupLvl() {
        self.mapNode = childNode(withName: "SCSTileNode") as? SKTileMapNode
        guard let mapNode = self.mapNode else { return }
        addManyNodes()
        physicsBody = SKPhysicsBody(edgeLoopFrom: .init(x: 0, y: mapNode.tileSize.height, width: mapNode.frame.size.width, height: mapNode.frame.size.height - mapNode.tileSize.height))
        
        physicsBody?.categoryBitMask = GameGlobals.PhysicsCategory.edge
        physicsBody?.contactTestBitMask = GameGlobals.PhysicsCategory.bird | GameGlobals.PhysicsCategory.block
        physicsBody?.collisionBitMask = GameGlobals.PhysicsCategory.all
        self.backgroundColor = self.view!.superview!.backgroundColor!.withAlphaComponent(0.2)
    }

    var addedCount = 0
    func addManyNodes() {
      /*  if addedCount <= 40 {
            self.addSCSNodes()
            addedCount += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(self.addedCount <= 10 ? 900000 : 900000), execute: {
                if self.addedCount <= 10 {
                    for _ in 0..<2 {
                        self.addManyNodes()
                    }
                } else {
                    self.addManyNodes()
                }
                
            })
        }*/
        guard let mapNode = self.mapNode else { return }
        
        
        let horizontalCount:CGFloat = 5
        var height = (mapNode.frame.size.height - (mapNode.tileSize.height))
        let step = height / 10
        let count = Int(step * horizontalCount)
        
        
        height = height - (step * CGFloat(addedCount))
        for _ in 0..<Int(horizontalCount) {
            self.addSCSNodes()
        }
        addedCount += 1
        if (count - addedCount) >= 0 && height >= 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(1000000), execute: {
                self.addManyNodes()
            })
        }
        
        /*for _ in 0..<count {
            for _ in 0..<Int(horizontalCount) {
                self.addSCSNodes(position: height)
            }
            height -= step
        }*/

    }
    
    func addSCSNodes(position:CGFloat? = nil) {
        let scsNodes:[SuccessNode] = scsType == .coloredConfety ? [
            .init(type: .Oval), .init(type: .YellowLine), .init(type: .RedLine), .init(type: .Oval), .init(type: .Oval), .init(type: .Oval)
        ] : [.init(type: .greenTriggles)]
        guard let scsNode = scsNodes.randomElement() else { return }
        scsNode.physicsBody = SKPhysicsBody(rectangleOf: scsNode.size)
        scsNode.physicsBody?.categoryBitMask = GameGlobals.PhysicsCategory.bird
        scsNode.physicsBody?.contactTestBitMask = GameGlobals.PhysicsCategory.all
        scsNode.physicsBody?.collisionBitMask = GameGlobals.PhysicsCategory.block | GameGlobals.PhysicsCategory.edge
        guard let mapNode = self.mapNode else { return }
        let height = mapNode.frame.size.height - (mapNode.tileSize.height)
        let maxWidth = self.frame.width - (mapNode.tileSize.width + scsNode.size.width + 120)
        let minWidth = mapNode.tileSize.width + scsNode.size.width + 120
        scsNode.position = .init(x: .random(in: minWidth..<maxWidth), y: position ?? height)
        scsNode.physicsBody?.isDynamic = true
        
        addChild(scsNode)

        
    }

    
    
    enum ObjectsType {
    case coloredConfety
        case greenTriaggles
    }
}

extension SuccessSKScene:SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch mask {
        case GameGlobals.PhysicsCategory.bird | GameGlobals.PhysicsCategory.edge:
            if let node = contact.bodyB.node as? SuccessNode {
                node.remove()
            } else if let node = contact.bodyA.node as? SuccessNode {
                node.remove()
            }
        default:
            break
        }
    }

}


struct GameGlobals {
    struct ZPosition {
        static let background: CGFloat = 0
        static let obstacles: CGFloat = 1
        static let bird: CGFloat = 2
        static let hudBackground: CGFloat = 10
        static let hudLabel: CGFloat = 11
    }

    struct PhysicsCategory {
        static let none:UInt32 = 0
        static let all:UInt32 = UInt32.max
        static let edge:UInt32 = 0x1
        static let bird:UInt32 = 0x1 << 1
        static let block:UInt32 = 0x1 << 2

    }
}
