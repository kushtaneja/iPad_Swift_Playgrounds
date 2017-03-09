//
//  HorizontalCollectionViewFlowLayout.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import UIKit

class HorizontalCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    private var preSizeChangeIndexPath: IndexPath?
    
    private var boundsCache = CGRect.zero
    
    private var lastOriginX: CGFloat = 0.0
    
    private var layoutAttributesCache = [UICollectionViewLayoutAttributes]()
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return CGSize.zero
        }

        guard shouldOverrideScrollingBehavior() else {
            let numberOfItem = collectionView.numberOfItems(inSection: 0)

            return CGSize(width: collectionView.bounds.width * CGFloat(numberOfItem), height: collectionView.bounds.height)
        }
        
        /// Allocate a huge scrolling area for horizontal scrolling.
        return CGSize(width: CGFloat.greatestFiniteMagnitude, height: collectionView.bounds.height)
    }

    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView, layoutAttributesCache.isEmpty, shouldOverrideScrollingBehavior() else {
            return
        }

        // Start the scroll view somewhere away from (0, 0) so user can scroll either direction.
        let itemCount = collectionView.numberOfItems(inSection: 0)
        var contentOffset = collectionView.contentOffset
        contentOffset.x = CGFloat(itemCount) * itemSize.width * 10000
        collectionView.contentOffset = contentOffset
        
        // Update layoutAttributesCache with default attributes information
        for itemIndex in 0..<itemCount {
            let indexPath = IndexPath(row: itemIndex, section: 0)
            if let layoutAttribute = layoutAttributesForItem(at: indexPath) {
                layoutAttributesCache.append(layoutAttribute)
            }
        }
        
        // Reposition items by putting item 0 in the center.
        _ = updateLayoutAttributes(withBounds: collectionView.bounds, scrollingForward: true)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        // Returns attributes from cache first if possible, otherwise use default layout attributes.
        guard shouldOverrideScrollingBehavior(), indexPath.row >= 0 && indexPath.row < layoutAttributesCache.count else {
            return super.layoutAttributesForItem(at: indexPath)
        }
        
        return layoutAttributesCache[indexPath.row]
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard shouldOverrideScrollingBehavior() else {
            return super.layoutAttributesForElements(in: rect)
        }
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Return any cache attribute intercepting with rect.
        for attributes in layoutAttributesCache where attributes.frame.intersects(rect) {
            layoutAttributes.append(attributes)
        }
        
        return layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView, shouldOverrideScrollingBehavior() else {
            return super.shouldInvalidateLayout(forBoundsChange: newBounds)
        }
        
        let sizeChanged = !boundsCache.size.equalTo(CGSize.zero) && !boundsCache.size.equalTo(newBounds.size)
        boundsCache = newBounds
        
        if sizeChanged {
            preSizeChangeIndexPath = collectionView.indexPathsForVisibleItems.first
        }

        let offsetX = collectionView.bounds.minX
        
        guard offsetX != lastOriginX || sizeChanged else {
            return super.shouldInvalidateLayout(forBoundsChange: newBounds)
        }
        
        let scrollingForward = offsetX > lastOriginX
        lastOriginX = offsetX
        
        let updated = updateLayoutAttributes(withBounds: newBounds, scrollingForward: scrollingForward, sizeChanged: sizeChanged)
        
        return updated
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard shouldOverrideScrollingBehavior() else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        
        let itemWidth = itemSize.width
        let offsetRemainder = proposedContentOffset.x.truncatingRemainder(dividingBy: itemWidth)
        var newContentOffset = proposedContentOffset
        
        guard offsetRemainder != 0 else {
            return newContentOffset
        }
        
        // Make sure newContentOffset always lands on an item.
        if ((velocity.x == 0 && offsetRemainder > (itemWidth / 2)) || velocity.x > 0) {
            newContentOffset.x += itemWidth - offsetRemainder
        }
        else {
            newContentOffset.x -= offsetRemainder
        }
        
        return newContentOffset
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        guard shouldOverrideScrollingBehavior(), let preBoundsChangeIndexPath = preSizeChangeIndexPath, let layoutAttribute = layoutAttributesForItem(at: preBoundsChangeIndexPath) else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
        
        return layoutAttribute.frame.origin
    }
    
    private func updateLayoutAttributes(withBounds bounds: CGRect, scrollingForward: Bool, sizeChanged: Bool = false) -> Bool {
        guard let collectionView = collectionView, shouldOverrideScrollingBehavior() else {
            return false
        }
        
        var updated = false
        let offsetX = bounds.minX
        let totalItemCount = collectionView.numberOfItems(inSection: 0)
        let itemWidth = bounds.width
        let maxSize = itemWidth * CGFloat(totalItemCount)
        let offSetRemainder = offsetX.truncatingRemainder(dividingBy: maxSize)
        let newCenterItem = offSetRemainder == 0 ? 0 : Int(offSetRemainder / itemWidth)
        
        var leftCellItemIndexes = [Int]()
        var rightCellItemIndexes = [Int]()
        
        let leftItemCount = totalItemCount / 2
        let rightItemCount = totalItemCount - leftItemCount

        // Scan through items from the center item to the end. Figure out which item should be on the right and which one should be on the left.
        for itemIndex in newCenterItem..<totalItemCount {
            if rightCellItemIndexes.count < rightItemCount {
                rightCellItemIndexes.append(itemIndex)
            }
            else {
                leftCellItemIndexes.append(itemIndex)
            }
        }
        
        // Scan through items from 0 to the (center item - 1) of the center item. Figure out which item should be on the right and which one should be on the left.
        for itemIndex in 0..<newCenterItem {
            if !rightCellItemIndexes.contains(itemIndex) {
                if rightCellItemIndexes.count < rightItemCount {
                    rightCellItemIndexes.append(itemIndex)
                }
                else if !leftCellItemIndexes.contains(itemIndex) {
                    leftCellItemIndexes.append(itemIndex)
                }
            }
        }
        
        let centerCellOriginX = CGFloat(Int(offsetX / itemWidth)) * itemWidth
        for itemIndex in 0..<totalItemCount {
            // Reposition items around the center item.
            var newOriginX = CGFloat.leastNormalMagnitude
            if let leftIndex = leftCellItemIndexes.index(of: itemIndex) {
                newOriginX = CGFloat(centerCellOriginX) - (itemWidth * CGFloat(leftCellItemIndexes.count - leftIndex))
            }
            else if let rightIndex = rightCellItemIndexes.index(of: itemIndex) {
                newOriginX = CGFloat(centerCellOriginX) + (itemWidth * CGFloat(rightIndex))
            }
            
            if newOriginX != CGFloat.leastNormalMagnitude {
                let layoutAttribute = layoutAttributesCache[itemIndex]
                if newOriginX != layoutAttribute.frame.minX || sizeChanged {
                    layoutAttribute.frame.origin.x = newOriginX
                    if sizeChanged {
                        layoutAttribute.frame.size = bounds.size
                    }
                    updated = true
                }
            }
        }
        
        return updated
    }
    
    func updateContentOffset() -> IndexPath? {
        guard let collectionView = collectionView, shouldOverrideScrollingBehavior() else {
            return nil
        }

        var newContentOffset = collectionView.contentOffset
        var indexPath = preSizeChangeIndexPath
        if indexPath == nil {
            newContentOffset.x += round(itemSize.width / 2)
            indexPath = collectionView.indexPathForItem(at: newContentOffset)
            preSizeChangeIndexPath = indexPath
        }
        
        let contentOffset = targetContentOffset(forProposedContentOffset: newContentOffset)
        collectionView.setContentOffset(contentOffset, animated: false)
        preSizeChangeIndexPath = nil
        
        return indexPath
    }
    
    func updateContentOffsetIfNeeded() {
        guard preSizeChangeIndexPath != nil else {
            return
        }
        
        _ = updateContentOffset()
    }

    /// Currently infinite horizontal scrolling is only supported for 3 items or more.
    func shouldOverrideScrollingBehavior() -> Bool {
        guard let collectionView = collectionView, collectionView.numberOfItems(inSection: 0) > 2 else {
            return false
        }
        
        return true
    }
}
