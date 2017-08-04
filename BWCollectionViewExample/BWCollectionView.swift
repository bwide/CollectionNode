//
//  BWCollectionView.swift
//
//  Created by Bruno Fulber Wide on 18/07/17.
//  Copyright © 2017 BW. All rights reserved.
//

import UIKit
import SpriteKit
public typealias Index = Int

public class BWCollectionView: SKNode {
    
    //MARK: - public
    /** the current index of the CollectionView */
    var index : Int = 0 { didSet{ delegate?.collectionView(didMoveTo: index) } }
    
    /** the spacing between elements of the CollectionView */
    var spacing : CGFloat = 0 { didSet{ setSpacing() } }
    
    /** the damping ratio for the collectionView (rate it deaccelerates) */
    var dampingRatio : Double = 3
    
    /** the object that acts as data source for the collection view */
    var dataSource : BWCollectionViewDataSource? { didSet{ reloadData() } }
    
    /** the object that acts as delegate for the collection view */
    var delegate : BWCollectionViewDelegate?
    
    //MARK: - initializers
    init(at view: SKView) {
        skview = view
        super.init()
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        
        skview?.addGestureRecognizer( panGestureRecognizer )
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /** extremely important to call this before leaving the scene*/
    override public func removeFromParent() {
        super.removeFromParent()
        skview?.removeGestureRecognizer( panGestureRecognizer )
    }
    
    //MARK: - private
    private var touchDistance : Double!
    private weak var skview: SKView?
    private var panGestureRecognizer : UIPanGestureRecognizer!
    private var biggestItem : SKNode!
    private var shouldBeginUpdating : Bool = false
    private var date : Date!
    private var velocity : Double!
    private var damping : Double!
    private var previousVelocity : Double!
    private var totalDistance : Double = 0
    private var origin : CGPoint!
    
    private func reloadData() {
        removeAllChildren()
        
        for index in 0..<dataSource!.numberOfItems() {
            let item = dataSource!.collectionView(self, itemFor: index)
            item.index = index
            addChild(item)
        }
        
        biggestItem = children.sorted{ $0.calculateAccumulatedFrame().size.width > $1.calculateAccumulatedFrame().size.width }.first!
        
        origin = children[0].position
        
        for index in 0..<children.count{
            children[index].position.x =
                (biggestItem.calculateAccumulatedFrame().size.width + spacing) * CGFloat(index)
        }
        index = 0
    }
    
    private func setSpacing(){
        for index in 0..<children.count{
            children[index].position.x =
                (biggestItem.calculateAccumulatedFrame().size.width + spacing) * CGFloat(index)
        }
    }
    
    @objc private func handlePan() {
        switch panGestureRecognizer.state {
        case .began:
            date = Date()
        case .changed:
            velocity = Double(panGestureRecognizer.velocity(in: self.skview).x)
            let time = date.timeIntervalSinceNow
            let distance = -(velocity * time)
            let action = SKAction.move(by: CGVector(dx: distance , dy: 0) , duration: 0)
            children.forEach{ $0.run(action, withKey: "move") }
            totalDistance += distance
            date = Date()
        case .ended:
            //keep moving
            date = Date()
            damping = 1
            previousVelocity = velocity
            shouldBeginUpdating = true
        default:
            print("nothing interesting happening")
        }
    }
    
    func update(_ currentTime: TimeInterval){// use this
        if shouldBeginUpdating {
            //create support variables and actions
            let time = date.timeIntervalSinceNow
            let distance = -(velocity * time)
            
            let action = SKAction.move(by: CGVector(dx: distance, dy: 0),
                                       duration: 0.0)
            //run actions
            children.forEach{ $0.run(action, withKey: "move") }
            
            //update context
            velocity = velocity > 0 ? velocity - damping : velocity + damping
            damping = damping + dampingRatio // make available to user
            date = Date()
            totalDistance += distance
            
            if abs( velocity ) > abs( previousVelocity ) {
                shouldBeginUpdating = false
                updateIndex()
                snap(to: index)
            }
            else { previousVelocity = velocity }
        }
    }
    
    //MARK: - Support methods
    private func updateIndex() {
        let currentNode =
            children.filter{ $0.isKind(of: BWCollectionViewItem.self) }.sorted{
                return $0.position.distance(to: origin) < $1.position.distance(to: origin)
                }.first!
        
        index = (currentNode as! BWCollectionViewItem).index
    }
    
    private func snap(to index: Index){
        var distance =
            origin.distance(to: children[index].position)
        
        if children[index].position.x >= 0 { distance = -distance }
        
        let action = SKAction.moveBy(x: distance,
                                     y: 0,
                                     duration: 0.3)
        
        children.forEach{ $0.run(action) }
        totalDistance = 0
    }
}

public class BWCollectionViewItem : SKNode {
    fileprivate var index : Index!
}

public protocol BWCollectionViewDataSource {
    /** the number of items displayed on this collectionView*/
    func numberOfItems() -> Int
    
    /**
     here you should return the item for each index in the collectionVIew
     - parameter collection: the collectionView in which the items are displayed
     - parameter index: the integer value of the index where the returned object will be at
     
     - returns: an SKNode to be displayed in each index
     */
    func collectionView(_ collection: BWCollectionView, itemFor index: Index) -> BWCollectionViewItem
}

public protocol BWCollectionViewDelegate {
    /**
     called each time the collection view changes it's current index
     
     - parameter index: current index of the collectionView
     */
    func collectionView(didMoveTo index: Index) -> Void
    
    func collectionView(didSelectItem item: BWCollectionViewItem, at index: Index ) -> Void
}

extension BWCollectionViewDelegate {
    func collectionView(didMoveTo index: Index) -> Void {  }
    func collectionView(didSelectItem item: BWCollectionViewItem, at index: Index ) -> Void {  }
}

extension CGPoint {
    fileprivate func distance(to point: CGPoint) -> CGFloat {
        let deltaX = point.x - x
        let deltaY = point.y - y
        return hypot(deltaX, deltaY)
    }
}



