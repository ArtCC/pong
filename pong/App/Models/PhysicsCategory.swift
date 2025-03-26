//
//  PhysicsCategory.swift
//  pong
//
//  Created by Arturo Carretero Calvo on 26/3/25.
//

import Foundation

enum PhysicsCategory {
    static let Ball: UInt32 = 0b1
    static let Paddle: UInt32 = 0b10
    static let Edge: UInt32 = 0b100
}
