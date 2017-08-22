//
//  GameScene.swift
//  SKCollectionViewExample
//
//  Created by Bruno Fulber Wide on 31/07/17.
//  Copyright © 2017 BW. All rights reserved.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene, BWCollectionViewDataSource, BWCollectionViewDelegate {
    
    var emojiCollection : BWCollectionView!
    
    override func didMove(to view: SKView) {
        emojiCollection = BWCollectionView(at: view)
        emojiCollection.dataSource = self
        emojiCollection.delegate = self
        
        emojiCollection.position = CGPoint(x: size.width*0.5,
                                           y: size.height*0.5)
        
        addChild(emojiCollection)
    }
    
    func numberOfItems() -> Int {
        return EmojiModel.default.emojis.count
    }
    
    func collectionView(_ collection: BWCollectionView, itemFor index: Index) -> BWCollectionViewItem {
        //create and configure an item
        let item = EmojiItem()
        item.emoji = EmojiModel.default.emojis[index]
        return item
    }
    
    override func update(_ currentTime: TimeInterval) {
        //be sure to call this so the collection works properly
        emojiCollection.update(currentTime)
    }
    
    func collectionView(didMoveTo index: Index) {
        //custom animation
        let moveUp =
            SKAction.moveTo(y: 50, duration: 0.1)
        let moveDown =
            SKAction.moveTo(y: 0, duration: 0.1)
        let shrink =
            SKAction.resize(byWidth: 2,
                            height: 2,
                            duration: 0)
        
        let group = SKAction.group([ moveDown, shrink ])
        
        emojiCollection.children[index].run(moveUp)
        
        emojiCollection.children.filter {
            emojiCollection.children.index(of: $0) != index
        }.forEach{
            $0.run(group)
        }
    }
    
    func collectionView(didSelectItem item: BWCollectionViewItem, at index: Index) {
        print("selected \(item.name ?? "noNameItem") at index \(index.description)")
    }
}
