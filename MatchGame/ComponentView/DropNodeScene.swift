//
//  DropNodeScene.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 18.11.2024.
//

import Foundation
import SpriteKit

class DropNodeScene: SKScene, SKPhysicsContactDelegate {
    
    let groundCategory: UInt32 = 0x1 << 0
    let redNodeCategory: UInt32 = 0x1 << 1
    var dropped:(()->())?
    override func didMove(to view: SKView) {
        backgroundColor = .clear
        let superView = view.superview?.superview as? DragImageView
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        self.physicsWorld.contactDelegate = self
        let redNode = SKSpriteNode(texture: .init(image: superView!.toImage()!), size: superView?.frame.size ?? .zero)
        redNode.position = CGPoint(x: size.width / 2, y: size.height)
        redNode.physicsBody = SKPhysicsBody(rectangleOf: redNode.size)
        redNode.physicsBody?.mass = 0.1
        redNode.physicsBody?.categoryBitMask = redNodeCategory
        redNode.physicsBody?.contactTestBitMask = groundCategory
        redNode.physicsBody?.isDynamic = true
        redNode.physicsBody?.allowsRotation = true
        redNode.physicsBody?.angularDamping = 1
        redNode.physicsBody?.affectedByGravity = true
        
        addChild(redNode)
        
        
        let ground = SKNode()
        ground.position = CGPoint(x: size.width / 2, y: 0)
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 10))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = groundCategory
        
        addChild(ground)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA.categoryBitMask
        let bodyB = contact.bodyB.categoryBitMask
        if (bodyA == redNodeCategory && bodyB == groundCategory) ||
            (bodyA == groundCategory && bodyB == redNodeCategory) {
            dropped?()
            dropped = nil
            self.physicsWorld.contactDelegate = nil
        }
    }
}
