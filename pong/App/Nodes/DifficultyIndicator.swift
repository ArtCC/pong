//
//  DifficultyIndicator.swift
//  pong
//
//  Created by Arturo Carretero Calvo on 26/3/25.
//

import SpriteKit

final class DifficultyIndicator: SKNode {
    // MARK: - Properties

    private let label: SKLabelNode
    private let background: SKShapeNode

    // MARK: - Init

    override init() {
        label = SKLabelNode()
        background = SKShapeNode()

        super.init()

        label.fontSize = 30
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center

        background.strokeColor = .white
        background.fillColor = .black
        background.lineWidth = 2

        addChild(background)
        addChild(label)

        self.isHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public functions

    func show(text: String, at position: CGPoint) {
        label.text = text
        label.position = .zero

        let padding: CGFloat = 20
        let size = CGSize(width: label.frame.width + padding, height: label.frame.height + padding)
        let rect = CGRect(origin: CGPoint(x: -size.width/2, y: -size.height/2), size: size)

        background.path = CGPath(rect: rect, transform: nil)

        self.position = position
        self.isHidden = false

        let actions = SKAction.sequence([
            .fadeIn(withDuration: 0.5),
            .wait(forDuration: 2.0),
            .fadeOut(withDuration: 0.5)
        ])

        self.run(actions)
    }
}
