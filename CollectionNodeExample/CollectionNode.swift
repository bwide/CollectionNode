//
//  CollectionNode.swift
//
//  Created by Bruno Fulber Wide on 18/07/17.
//  Copyright © 2017 BW. All rights reserved.
//

import UIKit
import SpriteKit
public typealias Index = Int

public class CollectionNode: SKNode {
    
    //MARK: - public
    /** the current index of the CollectionNode */
    private(set) public var index: Int = 0 { didSet{ delegate?.collectionNode(self, didShowItemAt: index) } }
    
    /** the object that acts as data source for the collection view */
    public weak var dataSource: CollectionNodeDataSource? { didSet{ reloadData() } }
    
    /** the object that acts as delegate for the collection view */
    public weak var delegate: CollectionNodeDelegate?
    
    /** returns all the children of this node that are CollectionNodeItems  */
    public var items: [CollectionNodeItem] {
        var nodes: [CollectionNodeItem] = []
        children.forEach{
            if let item = $0 as? CollectionNodeItem {
                nodes.append(item)
            }
        }
        return nodes
    }
    
    //MARK: - Default values
    /** the spacing between elements of the CollectionNode */
    public var spaceBetweenItems: CGFloat = 5 { didSet{ setSpacing() } }
    
    
    //MARK: - initializers
    public init(at view: SKView) {
        skview = view
        super.init()
        skview?.addGestureRecognizer( panGestureRecognizer )
    }
    
    deinit {
        skview?.removeGestureRecognizer( panGestureRecognizer )
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func removeFromParent() {
        super.removeFromParent()
        skview?.removeGestureRecognizer( panGestureRecognizer )
    }
    
    //MARK: - Public methods
    /**
     To be called on the scene's update. Allows this node to animate when touch is released
     
     - parameter dampingRatio: the ratio for the collectionNode deacceleration (0 to 1 meaning the percentage of speed to deaccelerate when touch is released, default is 1%)
     */
    public func update(_ currentTime: TimeInterval, dampingRatio: Double = 0.01){
        if shouldBeginUpdating {
            updateIndex()
            
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
    
    /**
     snaps to an item at a given index
     
     - parameter duration: The duration of the snap animation in seconds (default is 0.3)
     */
    public func snap(to index: Index, withDuration duration: Double = 0.3) {
        
        var distance =
            origin.distance(to: children[index].position)
        
        if children[index].position.x >= 0 { distance = -distance }
        
        let action = SKAction.moveBy(x: distance,
                                     y: 0,
                                     duration: duration)
        
        
        children.forEach{ $0.run(action) }
        totalDistance = 0
    }
    
    /** reloads all the items in the collection */
    public func reloadData() {
        removeAllChildren()
        
        for index in 0..<dataSource!.numberOfItems() {
            let item = dataSource!.collectionNode(self, itemFor: index)
            item.index = index
            addChild(item)
        }
        
        biggestItem = children.sorted{ $0.calculateAccumulatedFrame().size.width > $1.calculateAccumulatedFrame().size.width }.first!
        origin = children[0].position
        index = 0
        
        setSpacing()
    }
    
    //MARK: - private
    private weak var skview: SKView?
    private var touchDistance : Double!
    private var biggestItem : SKNode!
    private var shouldBeginUpdating : Bool = false
    private var date : Date!
    private var pureVelocity : Double!
    private var trueVelocity : Double!
    private var previousVelocity : Double!
    private var damping : Double!
    fileprivate var totalDistance : Double = 0
    private var origin : CGPoint!
    private lazy var panGestureRecognizer : UIPanGestureRecognizer! = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    
    fileprivate func setSpacing(){
        for index in 0..<children.count{
            children[index].position.x =
                (biggestItem.calculateAccumulatedFrame().size.width + spaceBetweenItems) * CGFloat(index)
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
    
    
    //MARK: - Support methods
    private func updateIndex() {
        let currentNode =
            children.filter{ $0.isKind(of: CollectionNodeItem.self) }.sorted{
                return $0.position.distance(to: origin) < $1.position.distance(to: origin)
                }.first!
        
        index = (currentNode as! CollectionNodeItem).index
    }
}


//MARK: - collection node item
open class CollectionNodeItem: SKNode {
    
    fileprivate var index : Index!
    
    fileprivate var collection: CollectionNode { return self.parent as! CollectionNode }
    
    
    public override init() {
        super.init()
        isUserInteractionEnabled = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if collection.totalDistance <= 5 { collection.delegate?.collectionNode(collection, didSelectItem: self, at: self.index) }
    }
}

public protocol CollectionNodeDataSource: class {
    /** - returns: the number of items to be displayed on this collectionNode */
    func numberOfItems() -> Int
    
    /**
     here you should return the item for each index in the collectionVIew
     - parameter collection: the collectionNode in which the items are displayed
     - parameter index: the integer value of the index where the returned object will be at
     
     - returns: an SKNode to be displayed in each index
     */
    func collectionNode(_ collection: CollectionNode, itemFor index: Index) -> CollectionNodeItem
}

public protocol CollectionNodeDelegate: class {
    /**
     called each time the collection view changes it's current index
     
     - parameter index: current index of the collectionNode
     */
    func collectionNode(_ collectionNode: CollectionNode, didShowItemAt index: Index) -> Void
    /**
     called each time an item is selected
     */
    func collectionNode(_ collectionNode: CollectionNode, didSelectItem item: CollectionNodeItem, at index: Index ) -> Void
}

public extension CollectionNodeDelegate {
    func collectionNode(_ collectionNode: CollectionNode, didShowItemAt index: Index) -> Void {  }
    func collectionNode(_ collectionNode: CollectionNode, didSelectItem item: CollectionNodeItem, at index: Index ) -> Void {  }
}

private extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let deltaX = point.x - x
        let deltaY = point.y - y
        return hypot(deltaX, deltaY)
    }
}



