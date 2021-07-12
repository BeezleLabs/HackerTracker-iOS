//
//  PongScene.swift
//  hackertracker
//
//  Created by Benjamin Humphries on 7/20/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import SpriteKit

class PongScene: SKScene, SKPhysicsContactDelegate {
    let xPos: CGFloat = 135.0

    var left: SKSpriteNode?
    var right: SKSpriteNode?
    var skull: SKSpriteNode?

    var skullPhysicsBody: SKPhysicsBody?

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        left = childNode(withName: "left") as? SKSpriteNode
        right = childNode(withName: "right") as? SKSpriteNode
        skull = childNode(withName: "skull") as? SKSpriteNode

        createFrameCollision()

        skullPhysicsBody = skull?.physicsBody
        skullPhysicsBody?.usesPreciseCollisionDetection = true
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        createFrameCollision()
    }

    func createFrameCollision() {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.usesPreciseCollisionDetection = true
        physicsBody?.categoryBitMask = .max
        physicsBody?.collisionBitMask = .max
        physicsBody?.restitution = 1
        physicsBody?.friction = 0
    }

    func play() {
        reset()
        startingAnimations {
            self.startGame()
        }
    }

    func reset() {
        skull?.physicsBody?.isDynamic = false
        left?.removeAllActions()
        right?.removeAllActions()

        left?.position = CGPoint(x: -1, y: 1)
        left?.zRotation = CGFloat(1.04719758 * 8.0 * .pi)

        right?.position = CGPoint(x: 1, y: 1)
        right?.zRotation = CGFloat(-1.04719758 * 8.0 * .pi)

        skull?.position = CGPoint(x: 0, y: 12)
        skull?.zRotation = 0.0
    }

    private func startingAnimations(completion: @escaping () -> Swift.Void) {
        let leftAction = SKAction.sequence([
            .wait(forDuration: 0.2),
            .group([
                .move(to: CGPoint(x: -xPos, y: 0), duration: 0.4),
                .rotate(toAngle: 0.0, duration: 0.5),
            ]),
        ])

        left?.run(leftAction)

        let rightAction = SKAction.sequence([
            .wait(forDuration: 0.2),
            .group([
                .move(to: CGPoint(x: xPos, y: 0), duration: 0.4),
                .rotate(toAngle: 0.0, duration: 0.5),
            ]),
        ])

        right?.run(rightAction) {
            self.skull?.physicsBody?.isDynamic = true
            completion()
        }
    }

    private func startGame() {
        guard let skull = skull else {
            print("skull is nil")
            return
        }

        let duration = 0.5

        let leftPlay = SKAction.repeatForever(
            .sequence([
                .wait(forDuration: 0.05),
                .run {
                    let xPos = self.skull?.position.x ?? 0
                    if xPos < 0 {
                        self.left?.run( .move(to: CGPoint(x: -self.xPos, y: skull.position.y), duration: duration / 8))
                    } else {
                        self.left?.run( .move(to: CGPoint(x: -self.xPos, y: -skull.position.y), duration: duration))
                    }
                },
            ])
        )
        left?.run(leftPlay, withKey: "leftPlay")

        let rightPlay = SKAction.repeatForever(
            .sequence([
                .wait(forDuration: 0.05),
                .run {
                    let xPos = self.skull?.position.x ?? 0
                    if xPos < 0 {
                        self.right?.run( .move(to: CGPoint(x: self.xPos, y: -skull.position.y), duration: duration))
                    } else {
                        self.right?.run( .move(to: CGPoint(x: self.xPos, y: skull.position.y), duration: duration / 8))
                    }
                },
            ])
        )
        right?.run(rightPlay, withKey: "rightPlay")

        let sign = Double.random(in: 0...1) - 0.5 > 0 ? 1.0 : -1.0
        skull.physicsBody?.applyImpulse(CGVector(dx: sign * 0.9, dy: sign * 0.9))
    }
}
