//
//  NodeFactory.swift
//  pong
//
//  Created by Arturo Carretero Calvo on 26/3/25.
//

import SpriteKit

enum NodeFactory {
    static func makePaddle(at position: CGPoint) -> SKSpriteNode {
        let paddle = SKSpriteNode(color: .white, size: CGSize(width: 20, height: 100))

        paddle.position = position
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.isDynamic = false
        paddle.physicsBody?.categoryBitMask = PhysicsCategory.Paddle
        paddle.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        paddle.physicsBody?.collisionBitMask = PhysicsCategory.Ball

        return paddle
    }

    static func makeBall(at position: CGPoint) -> SKSpriteNode {
        let ball = SKSpriteNode(color: .white, size: CGSize(width: 20, height: 20))

        ball.position = position
        ball.physicsBody = SKPhysicsBody(rectangleOf: ball.size)
        ball.physicsBody?.categoryBitMask = PhysicsCategory.Ball
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.Paddle | PhysicsCategory.Edge
        ball.physicsBody?.collisionBitMask = PhysicsCategory.Paddle | PhysicsCategory.Edge
        ball.physicsBody?.usesPreciseCollisionDetection = true
        ball.physicsBody?.allowsRotation = false
        ball.physicsBody?.restitution = 1.0
        ball.physicsBody?.linearDamping = 0.0
        ball.physicsBody?.friction = 0.0

        return ball
    }
}
