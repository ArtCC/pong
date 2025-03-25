//
//  GameScene.swift
//  pong
//
//  Created by Arturo Carretero Calvo on 25/3/25.
//

import SpriteKit

enum DifficultyLevel {
    case low
    case medium
    case high
}

enum PhysicsCategory {
    static let None: UInt32 = 0
    static let Ball: UInt32 = 0b1
    static let Paddle: UInt32 = 0b10
    static let Edge: UInt32 = 0b100
}

enum SpriteType {
    case enemy
    case player
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
    var difficultyLevel: DifficultyLevel = .low {
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
            enemySpeed = 0.12
        case .medium:
            enemySpeed = 0.085
        case .high:
            enemySpeed = 0.08
        }

        var enemyTargetPosition = enemyPaddle.position.y

        switch difficultyLevel {
        case .low:
            let distance = abs(ball.position.y - enemyPaddle.position.y)
            if distance > 55 {
                enemyTargetPosition = ball.position.y + CGFloat.random(in: -40...40)
            }
        case .medium, .high:
            enemyTargetPosition = ball.position.y
        }

        enemyPaddle.run(SKAction.moveTo(y: enemyTargetPosition, duration: TimeInterval(enemySpeed)))

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
            newPosition = max(newPosition, playerPaddle.size.height / 2)
            newPosition = min(newPosition, size.height - playerPaddle.size.height / 2)

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
        createPaddle(ofType: .enemy)
        createPaddle(ofType: .player)
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

        resetBall()
    }

    func createPaddle(ofType type: SpriteType) {
        let paddle = SKSpriteNode(color: .white, size: CGSize(width: 20, height: 100))
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.isDynamic = false
        paddle.physicsBody?.categoryBitMask = PhysicsCategory.Paddle
        paddle.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        paddle.physicsBody?.collisionBitMask = PhysicsCategory.Ball

        switch type {
        case .player:
            paddle.position = CGPoint(x: 75, y: frame.midY)

            playerPaddle = paddle
        case .enemy:
            paddle.position = CGPoint(x: frame.maxX - 50, y: frame.midY)

            enemyPaddle = paddle
        }

        addChild(paddle)
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
        playerScoreLabel = createScoreLabel(at: CGPoint(x: frame.midX - 100, y: frame.maxY - 75))
        enemyScoreLabel = createScoreLabel(at: CGPoint(x: frame.midX + 100, y: frame.maxY - 75))
    }

    func createDifficultyIndicator() {
        difficultyLabel = SKLabelNode(text: String(localized: "Medium difficulty"))
        difficultyLabel.verticalAlignmentMode = .center
        difficultyLabel.horizontalAlignmentMode = .center
        difficultyLabel.fontColor = .white
        difficultyLabel.fontSize = 30
        difficultyLabel.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        difficultyLabel.isHidden = true

        difficultyLabelBackground = SKShapeNode()
        difficultyLabelBackground.strokeColor = .white
        difficultyLabelBackground.lineWidth = 2
        difficultyLabelBackground.fillColor = .black
        difficultyLabelBackground.isHidden = true

        addChild(difficultyLabelBackground)
        addChild(difficultyLabel)
    }
}

private extension GameScene {
    func createScoreLabel(at position: CGPoint) -> SKLabelNode {
        let label = SKLabelNode(text: "0")
        label.fontColor = .white
        label.fontSize = 40
        label.position = position
        label.zPosition = 10

        addChild(label)

        return label
    }

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
            difficultyLabel.text = String(localized: "Low difficulty")
        case .medium:
            difficultyLabel.text = String(localized: "Medium difficulty")
        case .high:
            difficultyLabel.text = String(localized: "High difficulty")
        }

        let padding: CGFloat = 20
        let labelSize = difficultyLabel.frame.size
        let backgroundSize = CGSize(width: labelSize.width + padding, height: labelSize.height + padding)
        let backgroundRect = CGRect(origin: CGPoint(x: -backgroundSize.width / 2, y: -backgroundSize.height / 2),
                                    size: backgroundSize)

        difficultyLabelBackground.path = CGPath(rect: backgroundRect, transform: nil)
        difficultyLabelBackground.position = difficultyLabel.position

        let actions = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeOut(withDuration: 0.5)
        ])

        difficultyLabel.run(actions)
        difficultyLabelBackground.run(actions)
    }

    func resetBall() {
        ball.position = CGPoint(x: frame.midX, y: frame.midY)
        ball.physicsBody?.velocity = .zero

        let dx: CGFloat = Bool.random() ? 10 : -10
        let dy: CGFloat = CGFloat.random(in: -10...10)

        ball.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
    }
}
