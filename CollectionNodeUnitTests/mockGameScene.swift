//
//  mockGameScene.swift
//  CollectionNodeUnitTests
//
//  Created by Bruno Fulber Wide on 17/10/17.
//  Copyright © 2017 BW. All rights reserved.
//

import Foundation
import SpriteKit
import CollectionNode

class MockGameScene: SKScene {
    
    public var collection: CollectionNode!
    public var names: [String] = ["1", "2", "3"]
    
    override func didMove(to view: SKView) {
        collection = CollectionNode(at: view)
        collection.dataSource = self
    }
    
    override func update(_ currentTime: TimeInterval) {
        collection.update(currentTime)
    }
}

extension MockGameScene: CollectionNodeDataSource {
    func numberOfItems() -> Int {
        return names.count
    }
    
    func collectionNode(_ collection: CollectionNode, itemFor index: Index) -> CollectionNodeItem {
        let item = CollectionNodeItem()
        let node = SKLabelNode(text: names[index])
        item.addChild( node )
        
        return item
    }
}
