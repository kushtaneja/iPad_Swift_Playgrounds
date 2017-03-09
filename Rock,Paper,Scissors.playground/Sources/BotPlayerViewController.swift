//
//  BotPlayerViewController.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit

class BotPlayerViewController: PlayerViewController {
    
    override init(player: Player, game: Game) {
        super.init(player: player, game: game)
        
        ringTrackMultiplier = 0.16
        innerCircleMultiplier = 0.62
    }
    
    override func setupViews() {
        super.setupViews()
        actionView.setText(player.emoji)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented.")
    }

    override func prepareViewsForCurrentStatus() {
        super.prepareViewsForCurrentStatus()
        
        if game.status == .ready || game.status == .play {
            actionView.setText(player.emoji)
        }
    }
}
