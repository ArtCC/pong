//
//  GameScene.swift
//  pong
//
//  Created by Arturo Carretero Calvo on 18/5/24.
//

import SpriteKit

enum DifficultyLevel {
    case low
    case medium
    case high
}

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let Ball: UInt32 = 0b1
    static let Paddle: UInt32 = 0b10
    static let Edge: UInt32 = 0b100
}

final class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Properties

    var ball: SKSpriteNode!
    var enemyPaddle: SKSpriteNode!
    var playerPaddle: SKSpriteNode!
    var playerScoreLabel: SKLabelNode!
    var enemyScoreLabel: SKLabelNode!
    var difficultyLabel: SKLabelNode!
    var difficultyLabelBackground: SKShapeNode!
    var playerScore = 0
    var enemyScore = 0
    var consecutivePlayerPoints = 0
    var difficultyLevel: DifficultyLevel = .medium {
        didSet {
            updateDifficultyLabel()
        }
    }

    // MARK: - Override

    override func didMove(to view: SKView) {
        setup()
    }

    override func update(_ currentTime: TimeInterval) {
        let enemySpeed: CGFloat
        switch difficultyLevel {
        case .low:
            enemySpeed = 0.09
        case .medium:
            enemySpeed = 0.085
        case .high:
            enemySpeed = 0.08
        }

        let enemyTargetPosition = ball.position.y
        let action = SKAction.moveTo(y: enemyTargetPosition, duration: TimeInterval(enemySpeed))

        enemyPaddle.run(action)

        if ball.position.x <= playerPaddle.position.x - 20 {
            updateScore(forPlayer: false)
            resetBall()
        } else if ball.position.x >= enemyPaddle.position.x + 20 {
            updateScore(forPlayer: true)
            resetBall()
        }
    }

    // MARK: - UITouch

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)

            var newPosition = location.y
            newPosition = max(newPosition, playerPaddle.size.width / 2)
            newPosition = min(newPosition, size.width - playerPaddle.size.width / 2)

            playerPaddle.position = CGPoint(x: playerPaddle.position.x, y: newPosition)
        }
    }
}

// MARK: - Private
// MARK: - Setup

private extension GameScene {
    func setup() {
        backgroundColor = SKColor.black

        physicsWorld.contactDelegate = self

        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.categoryBitMask = PhysicsCategory.Edge

        createBall()
        createPlayer()
        createEnemy()
        createSeparationLine()
        createScores()
        createDifficultyIndicator()
    }

    func createBall() {
        ball = SKSpriteNode(color: .white, size: CGSize(width: 20, height: 20))
        ball.position = CGPoint(x: frame.midX, y: frame.midY)
        ball.physicsBody = SKPhysicsBody(rectangleOf: ball.size)
        ball.physicsBody?.categoryBitMask = PhysicsCategory.Ball
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.Paddle | PhysicsCategory.Edge
        ball.physicsBody?.collisionBitMask = PhysicsCategory.Paddle | PhysicsCategory.Edge
        ball.physicsBody?.usesPreciseCollisionDetection = true
        ball.physicsBody?.allowsRotation = false
        ball.physicsBody?.restitution = 1.0
        ball.physicsBody?.linearDamping = 0.0
        ball.physicsBody?.friction = 0.0

        addChild(ball)

        ball.physicsBody?.applyImpulse(CGVector(dx: 15, dy: 10))
    }

    func createPlayer() {
        playerPaddle = SKSpriteNode(color: .white, size: CGSize(width: 20, height: 100))
        playerPaddle.position = CGPoint(x: 75, y: frame.midY)
        playerPaddle.physicsBody = SKPhysicsBody(rectangleOf: playerPaddle.size)
        playerPaddle.physicsBody?.isDynamic = false
        playerPaddle.physicsBody?.categoryBitMask = PhysicsCategory.Paddle
        playerPaddle.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        playerPaddle.physicsBody?.collisionBitMask = PhysicsCategory.Ball

        addChild(playerPaddle)
    }

    func createEnemy() {
        enemyPaddle = SKSpriteNode(color: .white, size: CGSize(width: 20, height: 100))
        enemyPaddle.position = CGPoint(x: frame.maxX - 50, y: frame.midY)
        enemyPaddle.physicsBody = SKPhysicsBody(rectangleOf: enemyPaddle.size)
        enemyPaddle.physicsBody?.isDynamic = false
        enemyPaddle.physicsBody?.categoryBitMask = PhysicsCategory.Paddle
        enemyPaddle.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        enemyPaddle.physicsBody?.collisionBitMask = PhysicsCategory.Ball

        addChild(enemyPaddle)
    }

    func createSeparationLine() {
        let segmentHeight: CGFloat = 20.0
        let segmentWidth: CGFloat = 5.0
        let gapHeight: CGFloat = 10.0
        let numberOfSegments = Int(frame.height / (segmentHeight + gapHeight))

        for i in 0..<numberOfSegments {
            let segment = SKShapeNode(rectOf: CGSize(width: segmentWidth, height: segmentHeight))
            segment.fillColor = .white
            segment.position = CGPoint(x: frame.midX, y: CGFloat(i) * (segmentHeight + gapHeight) + segmentHeight / 2)

            addChild(segment)
        }
    }

    func createScores() {
        playerScoreLabel = SKLabelNode(text: "0")
        playerScoreLabel.fontColor = .white
        playerScoreLabel.fontSize = 40
        playerScoreLabel.position = CGPoint(x: frame.midX - 100, y: frame.maxY - 75)

        addChild(playerScoreLabel)

        enemyScoreLabel = SKLabelNode(text: "0")
        enemyScoreLabel.fontColor = .white
        enemyScoreLabel.fontSize = 40
        enemyScoreLabel.position = CGPoint(x: frame.midX + 100, y: frame.maxY - 75)

        addChild(enemyScoreLabel)
    }

    func createDifficultyIndicator() {
        difficultyLabel = SKLabelNode(text: "Dificultad media")
        difficultyLabel.verticalAlignmentMode = .center
        difficultyLabel.horizontalAlignmentMode = .center
        difficultyLabel.fontColor = .white
        difficultyLabel.fontSize = 30
        difficultyLabel.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        difficultyLabel.isHidden = true

        let backgroundSize = CGSize(width: difficultyLabel.frame.width + 20, height: difficultyLabel.frame.height + 20)
        difficultyLabelBackground = SKShapeNode(rectOf: backgroundSize, cornerRadius: 5)
        difficultyLabelBackground.strokeColor = .white
        difficultyLabelBackground.lineWidth = 2
        difficultyLabelBackground.fillColor = .black
        difficultyLabelBackground.position = difficultyLabel.position
        difficultyLabelBackground.isHidden = true

        addChild(difficultyLabel)
        addChild(difficultyLabelBackground)
    }
}

private extension GameScene {
    func updateScore(forPlayer player: Bool) {
        if player {
            playerScore += 1
            playerScoreLabel.text = "\(playerScore)"
            consecutivePlayerPoints += 1
        } else {
            enemyScore += 1
            enemyScoreLabel.text = "\(enemyScore)"
            consecutivePlayerPoints = 0
        }

        adjustDifficulty()
    }

    func adjustDifficulty() {
        if consecutivePlayerPoints >= 5 {
            difficultyLevel = .high
        } else if consecutivePlayerPoints == 0 {
            difficultyLevel = .low
        } else {
            difficultyLevel = .medium
        }
    }

    func updateDifficultyLabel() {
        difficultyLabel.isHidden = false
        difficultyLabelBackground.isHidden = false

        switch difficultyLevel {
        case .low:
            difficultyLabel.text = "Dificultad baja"
        case .medium:
            difficultyLabel.text = "Dificultad media"
        case .high:
            difficultyLabel.text = "Dificultad alta"
        }

        difficultyLabelBackground.position = difficultyLabel.position

        difficultyLabel.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeOut(withDuration: 0.5)
        ]))

        difficultyLabelBackground.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeOut(withDuration: 0.5)
        ]))
    }

    func resetBall() {
        ball.position = CGPoint(x: frame.midX, y: frame.midY)
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        ball.physicsBody?.applyImpulse(CGVector(dx: 10, dy: 10))
    }
}
