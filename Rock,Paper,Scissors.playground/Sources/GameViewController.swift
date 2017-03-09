//
//  GameViewController.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit
import CoreGraphics
import PlaygroundSupport

enum GameError {
    case noError
    case noActionsDefined
    case noOpponentDefined
    case tooManyOpponents
}

@objc(GameViewController)
public class GameViewController: UIViewController {
    
    public static func makeFromStoryboard() -> GameViewController {
        let bundle = Bundle(for: GameViewController.self)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        
        return storyboard.instantiateInitialViewController() as! GameViewController
    }
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }

    var gameError = GameError.noError
    
    public var game = Game() {
        didSet {
            humanPlayer.identifier = "*humanPlayerIdentifier*"
            
            if game.selectableActions.count == 0 && game.randomAction == nil {
                gameError = .noActionsDefined
            }
            
            if game.opponents.count == 0 {
                game.addOpponent("🤖", color: #colorLiteral(red: 0.8, green: 0, blue: 0.3882352941, alpha: 1))
                gameError = .noOpponentDefined
            }
            else if game.opponents.count > Game.Defaults.maxOpponents {
                gameError = .tooManyOpponents
            }
            
            if game.roundsToWin <= 0 {
               game.roundsToWin = 1
            }
            else if game.roundsToWin > 100 {
               game.roundsToWin = 100
            }
            
            setupViews()
            updateViews()
            setupBotPlayers()
        }
    }
    
    public var needAssessment = false
    
    private var status: GameStatus {
        set {
            game.status = newValue
        }
        get {
            return game.status
        }
    }
    
    private var opponentsCount: Int {
        return game.opponents.count
    }
    
    private enum Defaults {
        static let numberOfRandomDraw = 15

        static let tieText = "TIE"
        
        static let winText = "YOU WIN"
        
        static let loseText = "YOU LOSE"

        static let goActionText = "GO!"
        
        static let nextRoundActionText = "Next Round"
        
        static let newGameActionText = "New Game"
        
        static let tryAgainActionText = "Try Again"
        
        static let noActionsDefinedMessage = "You need to define at least one action to play the game."
        
        static let noOpponentDefinedMessage = "You need to define at least one opponent to play the game."
        
        static let tooManyOpponentsMessage = "You can have no more than four opponents for the game."
    }
    
    private let gradientView = GradientView()
    
    fileprivate var mainActionButton = RoundedLayerButton(type: .custom)
    
    private let resultLabel = UILabel()
    
    private let previousActionButton = UIButton()
    
    private let nextActionButton = UIButton()
    
    private var randomActionTimer: Timer?
    
    private var displayWinnersTimer: Timer?
    
    private var playerViewControllers = [PlayerViewController]()
    
    private var botPlayersInGameConstraints = [NSLayoutConstraint]()
    
    private var botPlayersInPlayConstraints = [NSLayoutConstraint]()

    private var shouldInitializeFonts = true

    private let contentLayoutGuide = UILayoutGuide()

    private let humanPlayerViewController: HumanPlayerViewController

    private let humanPlayer = Player(color: #colorLiteral(red: 0, green: 0.6392156863, blue: 0.8509803922, alpha: 1), type: .human)
    
    public required init?(coder aDecoder: NSCoder) {
        humanPlayerViewController = HumanPlayerViewController(player: humanPlayer, game: game)
        
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = SoundEffectsManager.default
        
        #if DEBUG
            setupGame()
        #endif

    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateLabels()
    }
    
    private func setupGame() {
        let game = Game()

        // Actions for the game.
        let rock = game.addAction("✊")
        let paper = game.addAction("🖐")
        let scissors = game.addAction("✌️")
        let hardRock = game.addAction("🤘")
        let doublePaper = game.addAction("🙌")
        let doubleScissors = game.addAction("🖖")
        
        // Rules for the actions.
        rock.beats([doubleScissors, scissors])
        doubleScissors.beats([scissors, doublePaper, paper])
        scissors.beats([doublePaper, paper])
        doublePaper.beats([paper, hardRock, rock])
        paper.beats([hardRock, rock])
        hardRock.beats([rock, doubleScissors, scissors])
        
        // 'ghost' hidden action that loses to all other actions.
        let ghost = game.addHiddenAction("👻")
        for action in game.actions {
            action.beats(ghost)
        }
        
        // 'unicorn' hidden action that beats all other actions.
        let unicorn = game.addHiddenAction("🦄")
        unicorn.beats(game.actions)
        
        // Opponents for the game.
        game.addOpponent("🐵", color: #colorLiteral(red: 0.239215686917305, green: 0.674509823322296, blue: 0.968627452850342, alpha: 1.0))
        game.addOpponent("🦁", color: #colorLiteral(red: 0.584313750267029, green: 0.823529422283173, blue: 0.419607847929001, alpha: 1.0))
        game.addOpponent("🐼", color: #colorLiteral(red: 0.556862771511078, green: 0.352941185235977, blue: 0.968627452850342, alpha: 1.0))
        game.addOpponent("🐸", color: #colorLiteral(red: 0.941176474094391, green: 0.498039215803146, blue: 0.352941185235977, alpha: 1.0))
        
        // Configurations for the game.
        game.roundsToWin = 5
        game.prize = "🍦"
        
        // Colors for the game.
        game.myColor = #colorLiteral(red: 0.960784316062927, green: 0.705882370471954, blue: 0.200000002980232, alpha: 1.0)
        game.outerRingColor = #colorLiteral(red: 0.10196078568697, green: 0.278431385755539, blue: 0.400000005960464, alpha: 1.0)
        game.innerCircleColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        game.mainButtonColor = #colorLiteral(red: 0.952941179275513, green: 0.686274528503418, blue: 0.133333340287209, alpha: 1.0)
        game.changeActionButtonsColor = #colorLiteral(red: 0.10196078568697, green: 0.278431385755539, blue: 0.400000005960464, alpha: 1.0)
        game.backgroundColors = [#colorLiteral(red: 0.474509805440903, green: 0.839215695858002, blue: 0.976470589637756, alpha: 1.0), #colorLiteral(red: 0.976470589637756, green: 0.850980401039124, blue: 0.549019634723663, alpha: 1.0)]

        self.game = game
        game.play()
    }

    private func calculateWinners() -> [Player] {
        var winners = [Player]()
        for currentPlayer in game.players {
            var isCurrentPlayerWinner = false
            for otherPlayer in game.players {
                if currentPlayer != otherPlayer {
                    let result = compare(currentPlayer.action, to: otherPlayer.action)
                    if result == .win {
                        isCurrentPlayerWinner = true
                    }
                    else if result == .lose {
                        isCurrentPlayerWinner = false
                        break
                    }
                }
            }
            
            if isCurrentPlayerWinner {
                winners.append(currentPlayer)
            }
        }
        
        return winners
    }
    
    private func compare(_ action: Action, to otherAction: Action) -> GameResult {
        if action.isWinner(comparedTo: otherAction) {
            return .win
        }
        else if otherAction.isWinner(comparedTo: action) {
            return .lose
        }
        
        return .tie
    }

    private func setupViews() {
        view.addSubview(gradientView)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        gradientView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addLayoutGuide(contentLayoutGuide)
        contentLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        contentLayoutGuide.topAnchor.constraint(equalTo: liveViewSafeAreaGuide.topAnchor, constant: 10).isActive = true
//        contentLayoutGuide.bottomAnchor.constraint(equalTo: liveViewSafeAreaGuide.bottomAnchor, constant: 10).isActive = true
        
        let edgeToEdgeSquareViewLayoutGuide = UILayoutGuide()
        view.addLayoutGuide(edgeToEdgeSquareViewLayoutGuide)
        edgeToEdgeSquareViewLayoutGuide.centerXAnchor.constraint(equalTo: contentLayoutGuide.centerXAnchor).isActive = true
        edgeToEdgeSquareViewLayoutGuide.centerYAnchor.constraint(equalTo: contentLayoutGuide.centerYAnchor).isActive = true
        edgeToEdgeSquareViewLayoutGuide.heightAnchor.constraint(equalTo: edgeToEdgeSquareViewLayoutGuide.widthAnchor).isActive = true
        edgeToEdgeSquareViewLayoutGuide.widthAnchor.constraint(lessThanOrEqualTo: contentLayoutGuide.widthAnchor, multiplier: 1).isActive = true
        edgeToEdgeSquareViewLayoutGuide.heightAnchor.constraint(lessThanOrEqualTo: contentLayoutGuide.heightAnchor, multiplier: 1).isActive = true
        
        let layoutGuideHeightConstraint = edgeToEdgeSquareViewLayoutGuide.heightAnchor.constraint(equalTo: contentLayoutGuide.heightAnchor)
        layoutGuideHeightConstraint.priority = 999
        layoutGuideHeightConstraint.isActive = true
        
        let layoutGuideWidthConstraint = edgeToEdgeSquareViewLayoutGuide.widthAnchor.constraint(equalTo: contentLayoutGuide.widthAnchor)
        layoutGuideWidthConstraint.priority = 999
        layoutGuideWidthConstraint.isActive = true

        let humanPlayerView = humanPlayerViewController.view!
        
        humanPlayerViewController.delegate = self
        humanPlayerView.translatesAutoresizingMaskIntoConstraints = false
        humanPlayerView.isHidden = true
        
        addChildViewController(humanPlayerViewController)
        view.addSubview(humanPlayerView)
        playerViewControllers.append(humanPlayerViewController)

        humanPlayerViewController.didMove(toParentViewController: self)
        humanPlayerView.centerXAnchor.constraint(equalTo: contentLayoutGuide.centerXAnchor).isActive = true
        humanPlayerView.heightAnchor.constraint(equalTo: humanPlayerView.widthAnchor).isActive = true
        humanPlayerView.widthAnchor.constraint(equalTo: edgeToEdgeSquareViewLayoutGuide.widthAnchor, multiplier: 0.42).isActive = true

        view.addSubview(mainActionButton)
        mainActionButton.addTarget(self, action: #selector(mainActionViewTapped), for: .touchUpInside)
        mainActionButton.translatesAutoresizingMaskIntoConstraints = false
        mainActionButton.titleLabel?.textAlignment = .center
        mainActionButton.setTitleColor(UIColor.white, for: .normal)
        mainActionButton.setTitle(Defaults.goActionText, for: .normal)
        mainActionButton.backgroundLayer.lineWidth = 4
        mainActionButton.backgroundLayer.strokeColor = UIColor(white: 0.97, alpha: 1).cgColor
        mainActionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mainActionButton.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -16).isActive = true
        mainActionButton.heightAnchor.constraint(lessThanOrEqualToConstant: 80).isActive = true
        mainActionButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 36).isActive = true
        mainActionButton.isHidden = true
        
        let mainActionViewMinTopAnchor = mainActionButton.topAnchor.constraint(equalTo: humanPlayerView.bottomAnchor, constant: 30)
        mainActionViewMinTopAnchor.priority = 800
        mainActionViewMinTopAnchor.isActive = true
        
        let mainActionViewHeightConstraint = mainActionButton.heightAnchor.constraint(equalTo: humanPlayerView.heightAnchor, multiplier: 0.3)
        mainActionViewHeightConstraint.priority = 901
        mainActionViewHeightConstraint.isActive = true

        view.addSubview(previousActionButton)

        let leftArrowImage = UIImage(named: "LeftArrow")!.withRenderingMode(.alwaysTemplate)
        previousActionButton.translatesAutoresizingMaskIntoConstraints = false
        previousActionButton.contentMode = .scaleAspectFit
        previousActionButton.setImage(leftArrowImage, for: .normal)
        previousActionButton.addTarget(self, action: #selector(changeAction(sender:)), for: .touchUpInside)
        
        let buttonSizeConstraint = previousActionButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.12)
        buttonSizeConstraint.priority = 999
        buttonSizeConstraint.isActive = true
        
        let buttonPadding: CGFloat = 6
        previousActionButton.widthAnchor.constraint(lessThanOrEqualTo: humanPlayerView.widthAnchor, multiplier: 0.18).isActive = true
        previousActionButton.trailingAnchor.constraint(equalTo: humanPlayerView.leadingAnchor, constant: -buttonPadding).isActive = true
        previousActionButton.centerYAnchor.constraint(equalTo: humanPlayerView.centerYAnchor).isActive = true
        previousActionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: round(leftArrowImage.size.width / 2)).isActive = true
        previousActionButton.heightAnchor.constraint(equalTo: previousActionButton.widthAnchor).isActive = true
        previousActionButton.isHidden = true

        view.addSubview(nextActionButton)
        
        let rightArrowImage = UIImage(named: "RightArrow")!.withRenderingMode(.alwaysTemplate)
        nextActionButton.translatesAutoresizingMaskIntoConstraints = false
        nextActionButton.contentMode = .scaleAspectFit
        nextActionButton.setImage(rightArrowImage, for: .normal)
        nextActionButton.addTarget(self, action: #selector(changeAction(sender:)), for: .touchUpInside)
        nextActionButton.widthAnchor.constraint(equalTo: previousActionButton.widthAnchor).isActive = true
        nextActionButton.heightAnchor.constraint(equalTo: previousActionButton.heightAnchor).isActive = true
        nextActionButton.leadingAnchor.constraint(equalTo: humanPlayerView.trailingAnchor, constant: buttonPadding).isActive = true
        nextActionButton.centerYAnchor.constraint(equalTo: humanPlayerView.centerYAnchor).isActive = true
        nextActionButton.isHidden = true

        view.addSubview(resultLabel)
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.alpha = 1
        resultLabel.textAlignment = .center
        resultLabel.isHidden = true
        resultLabel.centerXAnchor.constraint(equalTo: mainActionButton.centerXAnchor).isActive = true
        resultLabel.centerYAnchor.constraint(equalTo: mainActionButton.centerYAnchor).isActive = true

        let easterEggGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(easterEgg))
        easterEggGestureRecognizer.numberOfTouchesRequired = 2
        easterEggGestureRecognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(easterEggGestureRecognizer)
    }
    
    private func updateViews() {
        for playerViewController in playerViewControllers where playerViewController !== humanPlayerViewController {
            playerViewController.willMove(toParentViewController: nil)
            playerViewController.view.removeFromSuperview()
            playerViewController.removeFromParentViewController()
        }
        
        if game.backgroundColors.count > 1 {
            gradientView.isHidden = false
            gradientView.gradientLayer.colors = game.backgroundColors.map{ $0.cgColor }
        }
        else {
            gradientView.isHidden = true
            view.backgroundColor = game.backgroundColors.first ?? UIColor.white
        }
        
        mainActionButton.isHidden = false
        previousActionButton.isHidden = false
        nextActionButton.isHidden = false
        humanPlayerViewController.view.isHidden = false
        
        let buttonColor = game.changeActionButtonsColor == #colorLiteral(red: 0, green: 0.7457480216, blue: 1, alpha: 0) ? game.outerRingColor : game.changeActionButtonsColor
        previousActionButton.tintColor = buttonColor
        nextActionButton.tintColor = buttonColor
        resultLabel.textColor = game.resultLabelColor == #colorLiteral(red: 0, green: 0.7457480216, blue: 1, alpha: 0) ? game.mainButtonColor : game.resultLabelColor
        mainActionButton.backgroundLayer.fillColor = game.mainButtonColor.cgColor
        humanPlayerViewController.game = game

        botPlayersInPlayConstraints.removeAll()
    }
    
    private func setupBotPlayers() {
        guard let humanPlayerView = humanPlayerViewController.view else {
            return
        }

        let botsContainerLayoutGuide = UILayoutGuide()
        view.addLayoutGuide(botsContainerLayoutGuide)
        botsContainerLayoutGuide.widthAnchor.constraint(lessThanOrEqualTo: contentLayoutGuide.widthAnchor, multiplier: 1).isActive = true
        botsContainerLayoutGuide.centerXAnchor.constraint(equalTo: contentLayoutGuide.centerXAnchor).isActive = true
        
        let centerContentLayoutGuide = UILayoutGuide()
        view.addLayoutGuide(centerContentLayoutGuide)
        centerContentLayoutGuide.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor).isActive = true
        centerContentLayoutGuide.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor).isActive = true
        centerContentLayoutGuide.bottomAnchor.constraint(equalTo: mainActionButton.bottomAnchor).isActive = true
        centerContentLayoutGuide.topAnchor.constraint(equalTo: botsContainerLayoutGuide.topAnchor).isActive = true
        centerContentLayoutGuide.centerYAnchor.constraint(equalTo: contentLayoutGuide.centerYAnchor).isActive = true
        
        var firstBotPlayerView: UIView!
        var botReadyLayoutGuide: UILayoutGuide!
        var botLowerSpacerLayoutGuide: UILayoutGuide!
        
        for (index, player) in game.opponents.enumerated() {
            let playerViewController = BotPlayerViewController(player: player, game: game)
            addChildViewController(playerViewController)

            let playerView = playerViewController.view!
            playerView.alpha = 0
            playerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(playerView)
            playerViewController.didMove(toParentViewController: self)
            playerViewControllers.append(playerViewController)
            
            if index == 0 {
                firstBotPlayerView = playerView
                botReadyLayoutGuide = UILayoutGuide()
                view.addLayoutGuide(botReadyLayoutGuide)

                let botToHumanInGameSpacerMultiplier: CGFloat = game.opponents.count > 2 ? 1.15 : 1.3
                let botToHumanSpacerLayoutGuide = UILayoutGuide()
                
                view.addLayoutGuide(botToHumanSpacerLayoutGuide)
                botToHumanSpacerLayoutGuide.leadingAnchor.constraint(equalTo: centerContentLayoutGuide.leadingAnchor).isActive = true
                botToHumanSpacerLayoutGuide.trailingAnchor.constraint(equalTo: centerContentLayoutGuide.trailingAnchor).isActive = true
                botToHumanSpacerLayoutGuide.heightAnchor.constraint(equalTo: firstBotPlayerView.heightAnchor, multiplier: botToHumanInGameSpacerMultiplier).isActive = true
                humanPlayerView.topAnchor.constraint(equalTo: botToHumanSpacerLayoutGuide.bottomAnchor).isActive = true
                botsContainerLayoutGuide.leadingAnchor.constraint(equalTo: botReadyLayoutGuide.leadingAnchor).isActive = true
                botsContainerLayoutGuide.topAnchor.constraint(equalTo: botToHumanSpacerLayoutGuide.topAnchor).isActive = true
                botsContainerLayoutGuide.bottomAnchor.constraint(equalTo: humanPlayerView.centerYAnchor).isActive = true

                botLowerSpacerLayoutGuide = UILayoutGuide()
                view.addLayoutGuide(botLowerSpacerLayoutGuide)
                botLowerSpacerLayoutGuide.leadingAnchor.constraint(equalTo: botToHumanSpacerLayoutGuide.leadingAnchor).isActive = true
                botLowerSpacerLayoutGuide.trailingAnchor.constraint(equalTo: botToHumanSpacerLayoutGuide.trailingAnchor).isActive = true
                botLowerSpacerLayoutGuide.bottomAnchor.constraint(equalTo: humanPlayerView.topAnchor).isActive = true
                
                let lowerSpacerMultiplierOffset: CGFloat = opponentsCount == 3 ? 0.8 : 1
                botLowerSpacerLayoutGuide.heightAnchor.constraint(equalTo: botReadyLayoutGuide.heightAnchor, multiplier: botToHumanInGameSpacerMultiplier - lowerSpacerMultiplierOffset).isActive = true
                
                botReadyLayoutGuide.heightAnchor.constraint(equalTo: botReadyLayoutGuide.widthAnchor).isActive = true
                
                let botWidthConstraint = botReadyLayoutGuide.widthAnchor.constraint(equalTo: centerContentLayoutGuide.widthAnchor, multiplier: CGFloat(1.0 / CGFloat(game.opponents.count)))
                botWidthConstraint.priority = 800
                botWidthConstraint.isActive = true
                
                let defaultMultiplier: CGFloat = opponentsCount == 4 ? 0.66 : 0.6
                let maxWidthMultiplier = defaultMultiplier - (0.05 * CGFloat(game.opponents.count - 1))
                let botMaxWidthConstraint = botReadyLayoutGuide.widthAnchor.constraint(lessThanOrEqualTo: humanPlayerView.widthAnchor, multiplier: maxWidthMultiplier)
                botMaxWidthConstraint.priority = 801
                botMaxWidthConstraint.isActive = true
                
                let botMaxViewWidthConstraint = botReadyLayoutGuide.widthAnchor.constraint(lessThanOrEqualTo: centerContentLayoutGuide.widthAnchor, multiplier: 1.0 / CGFloat(game.opponents.count))
                botMaxViewWidthConstraint.priority = 802
                botMaxViewWidthConstraint.isActive = true
                
                let botHeightConstraint = botReadyLayoutGuide.heightAnchor.constraint(equalTo: centerContentLayoutGuide.heightAnchor, multiplier: CGFloat(1.0 / CGFloat(game.opponents.count)))
                botHeightConstraint.priority = 800
                botHeightConstraint.isActive = true
            }
            else {
                let botSpacerLayoutGuide = UILayoutGuide()
                view.addLayoutGuide(botSpacerLayoutGuide)
                
                let isPreviousPlayerLayoutLower = isBotPlayerLayoutLower(atIndex: (index - 1))
                let isCurrentPlayerLayoutLower = isBotPlayerLayoutLower(atIndex: index)
                let samePositionAsPreviousView = isPreviousPlayerLayoutLower == isCurrentPlayerLayoutLower
                
                var spacerMultiplier: CGFloat = (samePositionAsPreviousView || opponentsCount != Game.Defaults.maxOpponents) ? 0.1 : 0
                let spacerMultiplierOffset = CGFloat(Game.Defaults.maxOpponents - opponentsCount) * 0.1
                spacerMultiplier += spacerMultiplierOffset

                let spacerReadyWidthConstraint = botSpacerLayoutGuide.widthAnchor.constraint(equalTo: firstBotPlayerView.widthAnchor, multiplier: spacerMultiplier)
                spacerReadyWidthConstraint.priority = 700
                spacerReadyWidthConstraint.isActive = true

                if samePositionAsPreviousView {
                    let inPlayMultiplier = (opponentsCount == Game.Defaults.maxOpponents) ? spacerMultiplier * 3.6 : 0.1
                    let inPlayWidthConstraint = botSpacerLayoutGuide.widthAnchor.constraint(equalTo: firstBotPlayerView.widthAnchor, multiplier: inPlayMultiplier)
                    botPlayersInPlayConstraints.append(inPlayWidthConstraint)
                }
                
                let previousBotLayoutGuide = botReadyLayoutGuide!
                botSpacerLayoutGuide.heightAnchor.constraint(equalTo: botSpacerLayoutGuide.widthAnchor).isActive = true
                botSpacerLayoutGuide.leadingAnchor.constraint(equalTo: previousBotLayoutGuide.trailingAnchor).isActive = true
                botSpacerLayoutGuide.topAnchor.constraint(equalTo: botsContainerLayoutGuide.topAnchor).isActive = true
                
                botReadyLayoutGuide = UILayoutGuide()
                view.addLayoutGuide(botReadyLayoutGuide)
                botReadyLayoutGuide.leadingAnchor.constraint(equalTo: botSpacerLayoutGuide.trailingAnchor).isActive = true
                botReadyLayoutGuide.widthAnchor.constraint(equalTo: previousBotLayoutGuide.widthAnchor).isActive = true
                botReadyLayoutGuide.heightAnchor.constraint(equalTo: previousBotLayoutGuide.heightAnchor).isActive = true
            }

            var readyPositionConstraint: NSLayoutConstraint
            var inPlayPositionConstraint: NSLayoutConstraint
            
            if isBotPlayerLayoutLower(atIndex: index) {
                botReadyLayoutGuide.centerYAnchor.constraint(equalTo: botLowerSpacerLayoutGuide.topAnchor).isActive = true
                readyPositionConstraint = playerView.centerYAnchor.constraint(equalTo: botLowerSpacerLayoutGuide.topAnchor)
                
                if opponentsCount == Game.Defaults.maxOpponents - 1 {
                    inPlayPositionConstraint = playerView.centerYAnchor.constraint(equalTo: botLowerSpacerLayoutGuide.bottomAnchor, constant: -6)
                }
                else if opponentsCount == Game.Defaults.maxOpponents {
                    inPlayPositionConstraint = playerView.topAnchor.constraint(equalTo: botLowerSpacerLayoutGuide.bottomAnchor)
                    let paddings: CGFloat = 8
                    if playerViewController.player == game.opponents.first {
                        let trailingConstraint = playerView.trailingAnchor.constraint(equalTo: humanPlayerView.leadingAnchor, constant: -paddings)
                        botPlayersInPlayConstraints.append(trailingConstraint)
                    }
                    else if playerViewController.player == game.opponents.last {
                        let leadingConstraint = playerView.leadingAnchor.constraint(equalTo: humanPlayerView.trailingAnchor, constant: paddings)
                        botPlayersInPlayConstraints.append(leadingConstraint)
                    }
                }
                else {
                    inPlayPositionConstraint = playerView.centerYAnchor.constraint(equalTo: botLowerSpacerLayoutGuide.bottomAnchor)
                }
            }
            else {
                botReadyLayoutGuide.topAnchor.constraint(equalTo: botsContainerLayoutGuide.topAnchor).isActive = true
                readyPositionConstraint = playerView.topAnchor.constraint(equalTo: botReadyLayoutGuide.topAnchor)
                inPlayPositionConstraint = playerView.bottomAnchor.constraint(equalTo: botLowerSpacerLayoutGuide.bottomAnchor)
                // Adjust the position base on where the player will bounce down to.
                // In 2-4 player mode, we need to add some paddings otherwise the players will be too close.
                // In 5 player mode, since we are positioned around the curve, we can be down a bit more.
                inPlayPositionConstraint.constant = opponentsCount == Game.Defaults.maxOpponents ? 4 : -13
            }
            
            readyPositionConstraint.priority = 700
            readyPositionConstraint.isActive = true
            botPlayersInGameConstraints.append(readyPositionConstraint)
            botPlayersInPlayConstraints.append(inPlayPositionConstraint)

            playerView.widthAnchor.constraint(equalTo: botReadyLayoutGuide.widthAnchor).isActive = true
            playerView.heightAnchor.constraint(equalTo: botReadyLayoutGuide.heightAnchor).isActive = true
            
            let leadingConstraint = playerView.leadingAnchor.constraint(equalTo: botReadyLayoutGuide.leadingAnchor)
            leadingConstraint.priority = 700
            leadingConstraint.isActive = true
            
        }
        botsContainerLayoutGuide.trailingAnchor.constraint(equalTo: botReadyLayoutGuide.trailingAnchor).isActive = true
    }
    
    private func isBotPlayerLayoutLower(atIndex index: Int) -> Bool {
        guard opponentsCount > 2 && index >= 0 && index < game.opponents.count else {
            return false
        }

        let player = game.opponents[index]
        return player == game.opponents.first || player == game.opponents.last
    }
    
    @objc private func changeAction(sender: UIButton) {
        let isForward = (sender === nextActionButton)
        
        humanPlayerViewController.changeAction(forward:isForward)
    }

    private func positionPlayers(animated: Bool, gameEnded: Bool = false) {
        updateMainActionButtonText()
        
        let controlVisible = status == .ready || status == .endGame
        mainActionButton.isEnabled = controlVisible
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
            let newAlpha = CGFloat(controlVisible ? 1 : 0)
            self.previousActionButton.alpha = newAlpha
            self.nextActionButton.alpha = newAlpha
            self.mainActionButton.alpha = newAlpha
            
            for playerViewController in self.playerViewControllers {
                playerViewController.prepareViewsForCurrentStatus()
            }
        })

        let animateBotVisibility = gameEnded || playerViewControllers.last!.view.alpha == 0
        var damping: CGFloat = 0.46
        var inGameOffset: CGFloat = 0
        
        if animateBotVisibility {
            UIView.animate(withDuration: 0.5) {
                for playerViewController in self.playerViewControllers where playerViewController.player.type == .bot {
                    playerViewController.view.alpha = gameEnded ? 0 : 1
                    inGameOffset = -(playerViewController.view.bounds.height / 4.0)
                }
            }
            
            if gameEnded {
                damping = 0.6
                inGameOffset = inGameOffset * 1.3
            }
        }

        for inGameConstraint in self.botPlayersInGameConstraints {
            inGameConstraint.constant = animateBotVisibility ? inGameOffset : 0
        }
        
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            for inPlayConstraint in self.botPlayersInPlayConstraints {
                inPlayConstraint.isActive = self.status != .ready
            }

            self.view.layoutIfNeeded()
        })
    }

    @objc fileprivate func mainActionViewTapped() {
        var errorMessage: String?
        
        switch gameError {
            case .noError:
                break;
            case .noActionsDefined:
                errorMessage = Defaults.noActionsDefinedMessage
                break;
            case .noOpponentDefined:
                errorMessage = Defaults.noOpponentDefinedMessage
                break;
            case .tooManyOpponents:
                errorMessage = Defaults.tooManyOpponentsMessage
                break;
            
        }
        
        guard errorMessage == nil else {
            let alertController = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)

            return
        }
        
//        if needAssessment {
//            PlaygroundPage.current.assessmentStatus = .pass(message: nil)
//            needAssessment = false
//        }
//        
        SoundEffectsManager.default.play(soundEffect: .select)
        
        if status == .ready {
            status = .play
            positionPlayers(animated:true)

            let needRandomizer = game.actions.count > 1
            
            if randomActionTimer == nil && needRandomizer {
                Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { _ in
                    self.randomSelect()
                }
            }
            else {
                if let action = game.actions.first {
                    for playerViewController in playerViewControllers {
                        if playerViewController.player.isRandom {
                            playerViewController.action = action
                        }
                    }
                }
                
                let winners = calculateWinners()
                incrementWinCount(for: winners)
            }
        }
        else {
            var gameEnded = false
            
            if status == .endRound {
                status = .ready
            }
            else if status == .endGame {
                gameEnded = true
                resetGame()
            }
            
            for playerViewController in playerViewControllers {
                playerViewController.resetToDefault()
            }
            
            positionPlayers(animated: true, gameEnded: gameEnded)
        }
    }
    
    private func randomSelect() {
        var randomeCounter = 0

        randomActionTimer = Timer.scheduledTimer(withTimeInterval: 0.14, repeats: true) { _ in
            SoundEffectsManager.default.play(soundEffect: .random)
            randomeCounter += 1
            
            for playerViewController in self.playerViewControllers where playerViewController.player.isRandom {
                let numberPlayableActions = UInt32(self.game.actions.count)
                var randomNumber = Int(arc4random_uniform(numberPlayableActions))
                var newAction = self.game.actions[randomNumber]
                
                // Avoid having random from picking previous action unless it's the last random draw.
                if (newAction == playerViewController.action && randomeCounter != Defaults.numberOfRandomDraw - 1) {
                    if randomNumber == self.game.actions.count - 1 {
                        randomNumber = 0
                    }
                    else {
                        randomNumber += 1
                    }
                    newAction = self.game.actions[randomNumber]
                }
                playerViewController.action = newAction
            }
            
            if randomeCounter >= Defaults.numberOfRandomDraw {
                self.randomActionTimer?.invalidate()
                self.randomActionTimer = nil

                let winners = self.calculateWinners()
                self.incrementWinCount(for: winners)
            }
        }
    }

    private func incrementWinCount(for winners: [Player]) {
        displayWinnersTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { _ in
            self.displayWinnersTimer = nil
            
            var roundSoundEffect: SoundEffect = .roundTie
            var roundResult = GameResult.tie
            if winners.count > 0 {
                roundResult = .lose
                
                self.status = .endRound
                var gameEnded = false
                var loserPlayerViewControllers = [PlayerViewController]()
                
                for playerViewController in self.playerViewControllers {
                    if winners.contains(playerViewController.player) {
                        if playerViewController == self.humanPlayerViewController {
                            roundResult = .win
                        }
                        
                        playerViewController.increaseWinCount()
                        
                        if playerViewController.player.winCount >= self.game.roundsToWin {
                            gameEnded = true
                        }
                    }
                    else {
                        loserPlayerViewControllers.append(playerViewController)
                    }
                }

                roundSoundEffect = roundResult == .win ? .roundWin : .roundLose

                UIView.animate(withDuration: 0.4) {
                    for loserPlayerViewController in loserPlayerViewControllers {
                        loserPlayerViewController.gameLose()
                    }
                }
                
                if gameEnded {
                    self.status = .endGameAnimation
                    self.gameEnded()
                }
            }
            
            SoundEffectsManager.default.play(soundEffect: roundSoundEffect)
            self.game.roundResult = roundResult
            self.updateResultLabel()
        }
    }
    
    private func updateMainActionButtonText() {
        let endGame = status == .endGame
        
        var buttonText: String
        
        if endGame {
            if humanPlayerViewController.player.winCount >= game.roundsToWin {
                buttonText = Defaults.newGameActionText
            }
            else {
                buttonText = Defaults.tryAgainActionText
            }
        }
        else {
            if status == .endRound {
                buttonText = Defaults.nextRoundActionText
            }
            else {
                buttonText = Defaults.goActionText
            }
        }
        
        mainActionButton.setTitle(buttonText, for: .normal)
        view.layoutIfNeeded()
    }
    
    private func updateLabels() {
        let fontSize = round(mainActionButton.bounds.height * 0.58)
        let newFont = UIFont.systemFont(ofSize: fontSize, weight: 5)
        if resultLabel.font != newFont {
            resultLabel.font = newFont
            mainActionButton.titleLabel?.font = newFont
            
            let mainActionButtonHorizontalInsets = round(mainActionButton.bounds.height * 0.3)
            mainActionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: mainActionButtonHorizontalInsets, bottom: 0, right: mainActionButtonHorizontalInsets)
            view.setNeedsLayout()
        }
    }
    
    private func updateResultLabel() {
        func showActionButton(forStatus status: GameStatus) {
            self.status = status
            let endGame = status == .endGame
            let animationInterval: TimeInterval = endGame ? 0.5 : 0.33
            updateMainActionButtonText()
            
            UIView.animate(withDuration: animationInterval, delay: 0, options: [.allowUserInteraction], animations: {
                self.mainActionButton.alpha = 1
            })
        }
        
        var resultText: String
        switch game.roundResult {
            case .tie:
                resultText = Defaults.tieText
            case .win:
                resultText = Defaults.winText
            case .lose:
                resultText = Defaults.loseText
        }

        resultLabel.text = resultText
        resultLabel.isHidden = false
        resultLabel.alpha = 0
        
        UIView.animate(withDuration: 0.3, animations: {
            self.resultLabel.alpha = 1
        }) { _ in
            let gameEnding = self.status == .endGameAnimation
            let delay: TimeInterval = gameEnding ? 2 : 1
            
            UIView.animate(withDuration: 0.3, delay: delay, animations: {
                self.resultLabel.alpha = 0
            }) { _ in
                self.resultLabel.isHidden = true
                self.mainActionButton.isEnabled = true
                
                if gameEnding {
                    showActionButton(forStatus: .endGame)
                }
                else {
                    showActionButton(forStatus: .endRound)
                }
            }
        }
    }
    
    private func gameEnded() {
        for playerViewController in playerViewControllers {
            playerViewController.gameEnded()
        }
        
        Timer.scheduledTimer(withTimeInterval: PlayerViewController.Defaults.prizeTimerInterval, repeats: false) { _ in
            let roundSoundEffect: SoundEffect = self.game.roundResult == .win ? .gameWin : .gameLose
            SoundEffectsManager.default.play(soundEffect: roundSoundEffect)
        }
    }

    private func resetGame() {
        status = .ready
        mainActionButton.isEnabled = true
        for playerViewController in playerViewControllers {
            playerViewController.reset()
        }
    }
    
    @objc private func easterEgg() {
        if status == .ready {
            status = .endGameAnimation
            positionPlayers(animated: true)

            humanPlayerViewController.animateFullRing()
            humanPlayerViewController.player.winCount = game.roundsToWin

            Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { _ in
                SoundEffectsManager.default.play(soundEffect: .roundWin)
                self.game.roundResult = .win
                self.updateResultLabel()

                self.gameEnded()
            }
        }
    }
}

extension GameViewController: HumanPlayerViewControllerDelegate {
    func humanPlayerViewControllerUserWantsToContinuePlay(_ humanPlayerViewController: HumanPlayerViewController) {
        if mainActionButton.alpha == 1 {
            mainActionViewTapped()
        }
    }
}

//extension GameViewController: PlaygroundLiveViewSafeAreaContainer { }
