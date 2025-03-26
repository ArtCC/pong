//
//  ScoreLabel.swift
//  pong
//
//  Created by Arturo Carretero Calvo on 26/3/25.
//

import SpriteKit

final class ScoreLabel: SKLabelNode {
    // MARK: - Properties

    private(set) var score: Int = 0

    // MARK: - Init

    init(position: CGPoint) {
        super.init()
        self.fontColor = .white
        self.fontSize = 40
        self.position = position
        self.text = "0"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public functions

    func increment() {
        score += 1

        self.text = "\(score)"
    }

    func reset() {
        score = 0

        self.text = "0"
    }
}
