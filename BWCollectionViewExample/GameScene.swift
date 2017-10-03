//
//  GameScene.swift
//  SKCollectionViewExample
//
//  Created by Bruno Fulber Wide on 31/07/17.
//  Copyright © 2017 BW. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, CollectionNodeDataSource {
    
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
    
    func numberOfItems() -> Int {
        return EmojiModel.default.emojis.count
    }
    
    func collectionNode(_ collection: CollectionNode, itemFor index: Index) -> CollectionNodeItem {
        //create and configure an item
        let item = EmojiItem()
        item.emoji = EmojiModel.default.emojis[index]
        return item
    }
    
    override func update(_ currentTime: TimeInterval) {
        //be sure to call this so the collection works properly
        emojiCollection.update(currentTime)
    }
}

extension GameScene: CollectionNodeDelegate {
    func collectionNode(_ collectionNode: CollectionNode, didShowItemAt index: Index) {
        //animate
        collectionNode.item(at: index).setScale(1.2)
        collectionNode.children.filter{ emojiCollection.children.index(of: $0) != index }.forEach{ $0.setScale(1) }
    }
    
    func collectionNode(_ collectionNode: CollectionNode, didSelectItem item: CollectionNodeItem, at index: Index) {
        print("selected \(item.name ?? "noNameItem") at index \(index.description)")
    }
}
