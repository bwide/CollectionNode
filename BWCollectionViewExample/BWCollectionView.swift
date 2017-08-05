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
    public var index : Int = 0 { didSet{ delegate?.collectionView(didMoveTo: index) } }
    
    /** the spacing between elements of the CollectionView */
    public var spacing : CGFloat = 0 { didSet{ setSpacing() } }
    
    /** the damping ratio for the collectionView (0 to 1 meaning the percentage of speed to deaccelerate, default is 0.01) */
    public var dampingRatio : Double = 0.01
    
    /** the object that acts as data source for the collection view */
    public var dataSource : BWCollectionViewDataSource? { didSet{ reloadData() } }
    
    /** the object that acts as delegate for the collection view */
    public var delegate : BWCollectionViewDelegate?
    
    //MARK: - initializers
    public init(at view: SKView) {
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
    private weak var skview: SKView?
    private var touchDistance : Double!
    private var panGestureRecognizer : UIPanGestureRecognizer!
    private var biggestItem : SKNode!
    private var shouldBeginUpdating : Bool = false
    private var date : Date!
    private var pureVelocity : Double!
    private var trueVelocity : Double!
    private var previousVelocity : Double!
    private var damping : Double!
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
            updateIndex()
            
            pureVelocity = Double(panGestureRecognizer.velocity(in: self.skview).x)
            damping = index == 0 && pureVelocity > 0 || index == dataSource!.numberOfItems()-1 && pureVelocity < 0 ? pureVelocity*0.5 : 0
            trueVelocity = pureVelocity - damping
            
            let time = date.timeIntervalSinceNow
            let distance = -(trueVelocity * time)
            let action = SKAction.move(by: CGVector(dx: distance , dy: 0) , duration: 0)
            
            children.forEach{ $0.run(action, withKey: "move") }
            
            totalDistance += distance
            date = Date()
        case .ended:
            //keep moving
            date = Date()
            damping = 0
            previousVelocity = trueVelocity
            trueVelocity = pureVelocity
            shouldBeginUpdating = true
        default:
            print("nothing interesting happening")
        }
    }
    
    public func update(_ currentTime: TimeInterval){// use this
        if shouldBeginUpdating {
            let time = date.timeIntervalSinceNow
            let distance = -(trueVelocity * time)
            
            let action = SKAction.move(by: CGVector(dx: distance, dy: 0),
                                       duration: 0.0)
            //run actions
            children.forEach{ $0.run(action, withKey: "move") }
            
            //update context
            damping = damping + trueVelocity * dampingRatio
            trueVelocity = trueVelocity - damping
            date = Date()
            totalDistance += distance
            
            if abs( trueVelocity ) >= abs( previousVelocity ) {
                shouldBeginUpdating = false
                updateIndex()
                snap(to: index)
            }
            else { previousVelocity = trueVelocity }
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
                                     duration: 0.1)
        
        children.forEach{ $0.run(action) }
        totalDistance = 0
    }
}

open class BWCollectionViewItem : SKNode {
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

private extension BWCollectionViewDelegate {
    func collectionView(didMoveTo index: Index) -> Void {  }
    func collectionView(didSelectItem item: BWCollectionViewItem, at index: Index ) -> Void {  }
}

private extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let deltaX = point.x - x
        let deltaY = point.y - y
        return hypot(deltaX, deltaY)
    }
}



