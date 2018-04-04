//
//  GameScene.swift
//  SKCollectionViewExample
//
//  Created by Bruno Fulber Wide on 31/07/17.
//  Copyright © 2017 BW. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var emojiCollection : CollectionNode!
    
    override func didMove(to view: SKView) {
        emojiCollection = CollectionNode(at: view)
        
        emojiCollection.dataSource = self
        emojiCollection.delegate = self
        
        emojiCollection.spaceBetweenItems = 15
        
        emojiCollection.position = CGPoint(x: size.width*0.5,
                                           y: size.height*0.5)
        
        addChild(emojiCollection)
    }
    
    override func update(_ currentTime: TimeInterval) {
        //be sure to call this so the collection works properly
        emojiCollection.update(currentTime)
    }
}

extension GameScene: CollectionNodeDataSource {
    func numberOfItems() -> Int {
        return EmojiModel.default.emojis.count
    }
    
    func collectionNode(_ collection: CollectionNode, itemFor index: Index) -> CollectionNodeItem {
        //create and configure items
        let item = EmojiItem()
        item.emoji = EmojiModel.default.emojis[index]
        return item
    }
}

extension GameScene: CollectionNodeDelegate {
    func collectionNode(_ collectionNode: CollectionNode, didShowItemAt index: Index) {
        let growAction = SKAction.scale(to: 1.3, duration: 0.15)
        let shrinkAction = SKAction.scale(to: 1, duration: 0.15)
        
        collectionNode.items[index].run(growAction)
        collectionNode.items.filter{ emojiCollection.items.index(of: $0) != index }.forEach{ $0.run(shrinkAction) }
    }
    
    func collectionNode(_ collectionNode: CollectionNode, didSelectItem item: CollectionNodeItem, at index: Index) {
        print("selected \(item.name ?? "noNameItem") at index \(index)")
    }
}
