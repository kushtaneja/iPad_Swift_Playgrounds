//
//  HumanPlayerViewController.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit
import AVFoundation

protocol HumanPlayerViewControllerDelegate: class {
    func humanPlayerViewControllerUserWantsToContinuePlay(_ humanPlayerViewController: HumanPlayerViewController)
}

class HumanPlayerViewController: PlayerViewController {
    
    weak var delegate: HumanPlayerViewControllerDelegate?

    fileprivate var lastScrollX: CGFloat = 0
    
    fileprivate var currentCenterIndexPath: IndexPath?

    fileprivate var actionCollectionView: UICollectionView

    fileprivate let actionCollectionViewFlowLayout = HorizontalCollectionViewFlowLayout()
    
    private var previousRandomAction: Action?
    
    private var panGestureRecognizer: UIPanGestureRecognizer!
    
    fileprivate var selectableActions = [Action]()
    
    fileprivate enum Defaults {
        static let actionCollectionViewCellIdentifier = "ActionCollectionViewCellIdentifier"
    }

    override var game: Game {
        didSet {
            let playerColor = game.myColor.cgColor
            player.color = game.myColor
            roundsWonLayer.strokeColor = playerColor
            trackShapeLayer.strokeColor = game.outerRingColor.cgColor
            actionView.label.textColor = player.color
            innerCircleShapeLayer.fillColor = game.innerCircleColor.cgColor
            prizeLabel?.text = game.prize
            
            game.players = [player] + game.opponents
            selectableActions = game.selectableActions
            
            if let randomAction = game.randomAction {
                selectableActions += [randomAction]
            }
            
            actionCollectionView.reloadData()
            
            guard game.selectableActions.count > 0 else {
                return
            }
            
            action = game.selectableActions.first!
        }
    }

    override init(player: Player, game: Game) {
        actionCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: actionCollectionViewFlowLayout)
        
        super.init(player: player, game: game)
        
        innerCircleMultiplier = 0.71
        ringTrackMultiplier = 0.12
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented.")
    }

    override func setupViews() {
        super.setupViews()

        actionView.isHidden = true
        actionCollectionViewFlowLayout.scrollDirection = .horizontal
        actionCollectionViewFlowLayout.minimumLineSpacing = 0
        actionCollectionViewFlowLayout.minimumInteritemSpacing = 0

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(viewPanned))
        actionView.addGestureRecognizer(panGestureRecognizer)

        view.addSubview(actionCollectionView)
        actionCollectionView.translatesAutoresizingMaskIntoConstraints = false
        actionCollectionView.showsVerticalScrollIndicator = false
        actionCollectionView.showsHorizontalScrollIndicator = false
        actionCollectionView.alwaysBounceHorizontal = true
        actionCollectionView.register(ActionCollectionViewCell.self, forCellWithReuseIdentifier: Defaults.actionCollectionViewCellIdentifier)
        actionCollectionView.delegate = self
        actionCollectionView.dataSource = self
        actionCollectionView.leadingAnchor.constraint(equalTo: actionView.leadingAnchor).isActive = true
        actionCollectionView.trailingAnchor.constraint(equalTo: actionView.trailingAnchor).isActive = true
        actionCollectionView.topAnchor.constraint(equalTo: actionView.topAnchor).isActive = true
        actionCollectionView.bottomAnchor.constraint(equalTo: actionView.bottomAnchor).isActive = true
        actionCollectionView.backgroundColor = UIColor.clear
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        actionCollectionView.layer.cornerRadius = actionCollectionView.bounds.width / 2.0
        if !actionCollectionViewFlowLayout.itemSize.equalTo(actionCollectionView.bounds.size) {
            actionCollectionViewFlowLayout.itemSize = actionCollectionView.bounds.size
            
            var rect = CGRect.zero
            rect.origin = actionCollectionView.contentOffset
            rect.size = actionCollectionViewFlowLayout.itemSize
            _ = actionCollectionViewFlowLayout.shouldInvalidateLayout(forBoundsChange: rect)

            actionCollectionViewFlowLayout.invalidateLayout()
            actionCollectionViewFlowLayout.updateContentOffsetIfNeeded()
        }
    }
    
    override func resetToDefault() {
        super.resetToDefault()

        actionCollectionView.alpha = 1
        var addAction = action
        if player.isRandom, let previousRandomAction = previousRandomAction {
            addAction = previousRandomAction
        }
        
        action = addAction
    }
    
    override func prepareViewsForCurrentStatus() {
        super.prepareViewsForCurrentStatus()

        let playGame = game.status != .ready && game.status != .endGame
        actionCollectionView.isHidden = playGame
        actionView.isHidden = !playGame
        
        guard playGame else {
            player.isRandom = false
            return
        }
        
        var row: Int = player.action.emoji.isEmpty ? 0 : -1
        
        if let indexPath = actionCollectionViewFlowLayout.updateContentOffset() {
            row = indexPath.row
        }
        
        if row > -1 {
            action = selectableActions[row]
            
            if action.type == .random {
                player.isRandom = true
            }
            
            previousRandomAction = player.isRandom ? action : nil
        }
    }
    
    private func userWantsToContinuePlay() {
        if game.status == .endRound || game.status == .endGame {
            delegate?.humanPlayerViewControllerUserWantsToContinuePlay(self)
        }
    }
    
    @objc private func viewTapped(_ tapRecognizer: UITapGestureRecognizer) {
        if game.status == .ready {
            let touchPoint = tapRecognizer.location(in: view)
            let isForward = touchPoint.x > (view.bounds.size.width / 2)
            changeAction(forward: isForward)
        }
        else if game.status == .endRound || game.status == .endGame {
            userWantsToContinuePlay()
        }
    }
    
    @objc private func viewPanned(_ panRecognizer: UIPanGestureRecognizer) {
        if game.status == .endRound || game.status == .endGame {
            userWantsToContinuePlay()
        }
    }
    
    func changeAction(forward: Bool = true) {
        guard game.status == .ready && selectableActions.count > 1 else {
            return
        }
        
        let contentOffset = actionCollectionView.contentOffset
        let itemWidth = actionCollectionViewFlowLayout.itemSize.width
        let offsetRemainder = contentOffset.x.truncatingRemainder(dividingBy: itemWidth)
        var newContentOffset = actionCollectionView.contentOffset
        
        if offsetRemainder == 0 || itemWidth - offsetRemainder < 1 {
            if forward {
                newContentOffset.x += itemWidth
            }
            else {
                newContentOffset.x -= itemWidth
            }
        }
        else {
            if forward {
                newContentOffset.x += (itemWidth - offsetRemainder)
            }
            else {
                newContentOffset.x -= offsetRemainder
            }
        }
        
        actionCollectionView.setContentOffset(newContentOffset, animated: true)
    }
}

extension HumanPlayerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var centerPoint = scrollView.center
        centerPoint = scrollView.convert(centerPoint, from: scrollView.superview)

        guard let centerIndexPath = actionCollectionView.indexPathForItem(at: centerPoint) else {
            return
        }
        
        if currentCenterIndexPath?.row != centerIndexPath.row {
            if currentCenterIndexPath != nil {
                SoundEffectsManager.default.play(soundEffect: .scroll)
            }
            
            currentCenterIndexPath = centerIndexPath
        }
    }
}

extension HumanPlayerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectableActions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: Defaults.actionCollectionViewCellIdentifier, for: indexPath) as! ActionCollectionViewCell
        collectionViewCell.action = selectableActions[indexPath.row]
        collectionViewCell.actionView.label.textColor = player.color
        
        return collectionViewCell
    }
}
