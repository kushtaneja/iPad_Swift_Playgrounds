//
//  Game.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit

/// Game comparison possible outcomes.
enum GameResult {
    case tie
    case win
    case lose
}

/// Different game statuses for the game.
enum GameStatus {
    case ready
    case play
    case endRound
    case endGameAnimation
    case endGame
}

/**
 A class that contains the configurations for the game.
 
 - `actions`: An array of actions for the game.
 - `backgroundColors`: Gradient colors for the background of the game. A gradient stop is generated automatically for every color added to the array.
 - `changeActionButtonsColor`: Color for the Next and Previous buttons. If not set, `changeActionButtonsColor` defaults to the same color as `outerRingColor`
 - `innerCircleColor`: Color for the inner circle for all players.
 - `mainButtonColor`: Color for the main button for the game.
 - `myColor`: Color for the main player. This color shows rounds that the main player has won and is used for the particles shown when the main player wins a game.
 - `outerRingColor`: Color for the ring around the inner circle for all players.
 - `resultLabelColor`: Color for the label displayed when a round ends. If not set, `resultLabelColor` defaults to the same color as `mainButtonColor`
 - `roundsToWin`: The number of rounds a player needs to win in order to win the whole game.
 - `prize`: The emoji to show when a player wins a game.
 
 - `addAction(_ emoji: String)`: Create a new action for the game.
 - `addHiddenAction(_ emoji: String)`: Create a new hidden action for the game. A hidden action appears only if you’ve chosen the random action.
 - `addOpponent(_ emoji: String, color: UIColor)`: Add an opponent to the game. The maximum number of opponents for the game is four.
 */
public class Game {
    enum Defaults {
        static let minOpponents = 1

        static let maxOpponents = 4
    }
    
    /// The number of rounds a player needs to win in order to win the whole game.
    public var roundsToWin: UInt = 0
    
    /// The emoji to show when a player wins a game.
    public var prize = "🏆"
    
    /// An array of actions for the game.
    public var actions = [Action]()

    var opponents = [Player]()
    
    /// Color for the main player. This color shows rounds that the main player has won and is used for the particles shown when the main player wins a game.
    public var myColor: UIColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.8509803922, alpha: 1)
    
    /// Color for the label displayed when a round ends. If not set, `resultLabelColor` defaults to the same color as `mainButtonColor`
    public var resultLabelColor = #colorLiteral(red: 0, green: 0.7457480216, blue: 1, alpha: 0)

    /// Color for the Next and Previous buttons. If not set, `changeActionButtonsColor` defaults to the same color as `outerRingColor`
    public var changeActionButtonsColor = #colorLiteral(red: 0, green: 0.7457480216, blue: 1, alpha: 0)

    /// Color for the main button for the game.
    public var mainButtonColor = #colorLiteral(red: 0, green: 0.6392156863, blue: 0.8509803922, alpha: 1)

    /// Color for the ring around the inner circle for all players.
    public var outerRingColor = #colorLiteral(red: 0.7450980392, green: 0.8352941176, blue: 0.8980392157, alpha: 1)
    
    /// Color for the inner circle for all players.
    public var innerCircleColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    
    /// Gradient colors for the background of the game. A gradient stop is generated automatically for every color added to the array.
    public var backgroundColors = [#colorLiteral(red: 0.7843137255, green: 0.9058823529, blue: 1, alpha: 1), #colorLiteral(red: 0.9647058824, green: 0.9843137255, blue: 1, alpha: 1)]

    public var useDefaults = false
    
    public var canPlay = false
    
    var shouldDimLosers: Bool {
        return opponents.count > Defaults.minOpponents
    }
    
    var players = [Player]()
    
    var status: GameStatus = .ready
    
    var selectableActions = [Action]()
    
    var randomAction: Action?
    
    var roundResult = GameResult.tie
    
    public init() { }

    /**
     Add an opponent to the game. The maximum number of opponents for the game is four.
     
     - Parameters:
        - emoji: An emoji representation of the opponent.
        - color: A color for the opponent. This color shows the rounds that the opponent has won.
     */
    public func addOpponent(_ emoji: String, color: UIColor) {
        let opponent = Player(emoji, color: color, type: .bot)
        
        opponents += [opponent]
        opponent.identifier = opponent.emoji + "\(opponents.count)"
    }

    private func addAction(_ emoji: String, type: ActionType) -> Action {
        let action = Action(emoji, type: type)
        self.actions += [action]
        
        selectableActions.removeAll()
        selectableActions += self.actions.filter { !($0.type == .hidden) }
        
        if self.actions.count > selectableActions.count && randomAction == nil {
            randomAction = Action("?", type: .random)
        }

        return action
    }
    
    /**
     Create a new action for the game.
     
     - Parameters:
        - emoji: An emoji representation of the action.
     
     - Returns:
     Action: A new action object with the specified emoji.
     */
    public func addAction(_ emoji: String) -> Action {
        return addAction(emoji, type: .standard)
    }

    /**
     Create a hidden action for the game. This action appears only if you choose the random action that was automatically added to the game when you defined the hidden action.
     
     - Parameters:
        - emoji: An emoji representation of the hidden action.
     
     - Returns:
     Action: A hidden action object with the specified emoji.
     */
    public func addHiddenAction(_ emoji: String) -> Action {
        return addAction(emoji, type: .hidden)
    }

    /// Load default game settings.
    public func loadDefaultSettings() {
        useDefaults = true
    }

    /**
     Start playing the game.
     */
    public func play() {
        canPlay = true
    }
}
