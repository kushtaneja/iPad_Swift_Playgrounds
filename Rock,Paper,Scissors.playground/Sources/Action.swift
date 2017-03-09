//
//  Action.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit

/// Supported action types.
enum ActionType {
    case standard
    case random
    case hidden
}

/**
 A class that represents an action for the game. You can set an emoji to customize your action.

 - `beats(_ action: Action)`: Add an action that the current action can beat.
 - `beats(_ actions: [Action])`: Add an array of actions that the current action can beat.
 */
public class Action: Equatable {

    let type: ActionType
    
    let emoji: String

    var beatsActions = [Action]()

    // Use by subclass.
    func commonInit() { }
    
    init() {
        emoji = ""
        type = .standard
        commonInit()
    }
    
    /**
     Create a new action with an emoji.
     
     - Parameters:
       - emoji: An emoji representation for the action.
       - type: Action type for the action.
     
     - Returns: 
     Action: A new action object with the specified emoji.
     */
    init(_ emoji: String, type: ActionType = .standard) {
        self.type = type
        self.emoji = emoji
        commonInit()
    }

    /**
     Add an action that current action can beat.
     
     - Parameters:
       - action: An action that will lose to the current action.
     */
    public func beats(_ action: Action) {
        beats([action])
    }

    /**
     Add an array of actions that the current action can beat.
     
     - Parameters:
       - actions: An array of actions that will lose to the current action.
     */
    public func beats(_ actions: [Action]) {
        beatsActions += actions
    }
    
    /**
     Check to see if the current action beats the passed in action.
     
     - Parameters:
       - action: An action to compare the current action to.
     
     - Returns: 
     Bool: `true` if the current action beats the action passed in; otherwise, `false`.
     */
    func isWinner(comparedTo action: Action) -> Bool {
        return beatsActions.contains(action)
    }
    
    public static func == (leftAction: Action, rightAction: Action) -> Bool {
        return leftAction.emoji == rightAction.emoji
    }
}

