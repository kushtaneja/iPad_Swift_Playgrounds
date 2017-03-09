//#-hidden-code
//
//  Contents.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//
//#-end-hidden-code
/*:
 In this playground, you’ll configure the game Brick Breaker. You can set up the levels and game mechanics to put your own unique twist on the game!
 
 The goal in Brick Breaker is to destroy all the bricks while preventing the ball from going off the screen. Run the code to try it out!
 
 The following pages will teach you the various ways you can customize your game. Explore at your own pace, and see what fun creations you can make!
 */
//#-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(module, show, Swift)
//#-code-completion(currentmodule, show)
//#-code-completion(bookauxiliarymodule, show)
//#-code-completion(identifier, show, if, func, var, let, ., =, <=, >=, <, >, ==, !=, +, -, true, false, &&, ||, !, *, /)

import PlaygroundSupport

func setupBricks(columnCount: Int, rowCount: Int) {
    let brickColors = [
        [#colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1)],
        [#colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.6941176471, blue: 0.4117647059, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.6941176471, blue: 0.4117647059, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 1)],
        [#colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.6941176471, blue: 0.4117647059, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.6941176471, blue: 0.4117647059, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1)],
        [#colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 0), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 0), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 0), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 0), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 1)],
        [#colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 0), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 0), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 0), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 0), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 0), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 0)],
        [#colorLiteral(red: 0.3254901961, green: 0.6941176471, blue: 0.4117647059, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.6941176471, blue: 0.4117647059, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 0), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 0), #colorLiteral(red: 0.3254901961, green: 0.6941176471, blue: 0.4117647059, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.6941176471, blue: 0.4117647059, alpha: 1)],
        [#colorLiteral(red: 0.3254901961, green: 0.6941176471, blue: 0.4117647059, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.6941176471, blue: 0.4117647059, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 0), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 0), #colorLiteral(red: 0.3254901961, green: 0.6941176471, blue: 0.4117647059, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.6941176471, blue: 0.4117647059, alpha: 1)],
        [#colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 0), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 0), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 0), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 0), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 0), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 0)],
        [#colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 0), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 0), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 0), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 0), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 1)],
        [#colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.6941176471, blue: 0.4117647059, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.6941176471, blue: 0.4117647059, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1)],
        [#colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.6941176471, blue: 0.4117647059, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.6941176471, blue: 0.4117647059, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 1)],
        [#colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 1), #colorLiteral(red: 0.3254901961, green: 0.5960784314, blue: 1, alpha: 1)]
    ]
    
    for row in 0 ..< rowCount {
        for column in 0 ..< columnCount {
            let color = brickColors[row][column]
            guard color != #colorLiteral(red: 0.968627451, green: 0.3215686275, blue: 0.3215686275, alpha: 0) else { continue }
            
            let coordinate = Coordinate(column: column, row: row)
            let brick = Brick()
            brick.color = color
            
            place(brick, at: coordinate)
        }
    }
}
//#-end-hidden-code
//#-editable-code
playGame()
//#-end-editable-code
//#-hidden-code

level.setupBricks = setupBricks

if _playGameCalled {
    let gameViewController = GameViewController.loadFromStoryboard()
    PlaygroundPage.current.liveView = gameViewController
    gameViewController.game = Game(levels: [level])
}

//#-end-hidden-code
