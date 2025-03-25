//
//  StartScene.swift
//  pong
//
//  Created by Arturo Carretero Calvo on 25/3/25.
//

import SpriteKit

final class StartScene: SKScene {
    // MARK: - Properties

    private var startLabel: SKLabelNode!

    // MARK: - Override

    override func didMove(to view: SKView) {
        backgroundColor = .black

        startLabel = SKLabelNode(text: String(localized: "Touch to start"))
        startLabel.fontSize = 40
        startLabel.fontColor = .white
        startLabel.position = CGPoint(x: frame.midX, y: frame.midY)

        addChild(startLabel)

        let fade = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.2, duration: 0.8),
            SKAction.fadeAlpha(to: 1.0, duration: 0.8)
        ])

        startLabel.run(SKAction.repeatForever(fade))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let transition = SKTransition.fade(withDuration: 1.0)
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = .aspectFill

        view?.presentScene(gameScene, transition: transition)
    }
}
