//
//  Player.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit

enum PlayerType {
    case bot
    case human
}

class Player: Equatable {

    var emoji: String

    var color: UIColor
    
    var identifier: String

    let type: PlayerType

    var action: Action
    
    var winCount: UInt = 0
    
    var isRandom = false
    
    init(_ emoji: String = "", color: UIColor = UIColor.clear, type: PlayerType = .human) {
        action = Action()
        identifier = emoji
        self.emoji = emoji
        self.type = type
        self.color = color
        if type == .bot {
            isRandom = true
        }
    }
    
    public static func == (leftPlayer: Player, rightPlayer: Player) -> Bool {
        return leftPlayer.identifier == rightPlayer.identifier
    }
}
