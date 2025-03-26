//
//  GameScene.swift
//  pong
//
//  Created by Arturo Carretero Calvo on 25/3/25.
//

import SpriteKit

final class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Properties

    var ball: SKSpriteNode!
    var enemyPaddle: SKSpriteNode!
    var playerPaddle: SKSpriteNode!
    var playerScoreLabel: ScoreLabel!
    var enemyScoreLabel: ScoreLabel!
    var difficultyIndicator = DifficultyIndicator()
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
        createSeparationLine()
        createScores()

        playerPaddle = NodeFactory.makePaddle(at: CGPoint(x: 75, y: frame.midY))
        enemyPaddle = NodeFactory.makePaddle(at: CGPoint(x: frame.maxX - 50, y: frame.midY))

        addChild(playerPaddle)
        addChild(enemyPaddle)
        addChild(difficultyIndicator)
    }

    func createBall() {
        ball = NodeFactory.makeBall(at: CGPoint(x: frame.midX, y: frame.midY))

        addChild(ball)

        resetBall()
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
        playerScoreLabel = ScoreLabel(position: CGPoint(x: frame.midX - 100, y: frame.maxY - 75))
        enemyScoreLabel = ScoreLabel(position: CGPoint(x: frame.midX + 100, y: frame.maxY - 75))

        addChild(playerScoreLabel)
        addChild(enemyScoreLabel)
    }
}

private extension GameScene {
    func updateScore(forPlayer player: Bool) {
        if player {
            playerScoreLabel.increment()

            consecutivePlayerPoints += 1
        } else {
            enemyScoreLabel.increment()

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
        switch difficultyLevel {
        case .low:
            difficultyIndicator.show(text: String(localized: "Low difficulty"), at: CGPoint(x: frame.midX, y: frame.midY))
        case .medium:
            difficultyIndicator.show(text: String(localized: "Medium difficulty"), at: CGPoint(x: frame.midX, y: frame.midY))
        case .high:
            difficultyIndicator.show(text: String(localized: "High difficulty"), at: CGPoint(x: frame.midX, y: frame.midY))
        }
    }

    func resetBall() {
        ball.position = CGPoint(x: frame.midX, y: frame.midY)
        ball.physicsBody?.velocity = .zero

        let dx: CGFloat = Bool.random() ? 10 : -10
        let dy: CGFloat = CGFloat.random(in: -10...10)

        ball.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
    }
}
