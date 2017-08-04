//
//  GameScene.swift
//  SKCollectionViewExample
//
//  Created by Bruno Fulber Wide on 31/07/17.
//  Copyright © 2017 BW. All rights reserved.
//

import SpriteKit
import GameplayKit
import BWCollectionView
import BWCollectionViewItem
import BWCollectionViewDataSource


class GameScene: SKScene, BWCollectionViewDataSource {
    
    let emojis = [ Emoji("Heart Face", image: #imageLiteral(resourceName: "HeartFace")),
                   Emoji("Smiley Face", image: #imageLiteral(resourceName: "SmileyFace")),
                   Emoji("Space Invader", image: #imageLiteral(resourceName: "SpaceInvader")),
                   Emoji("Alien", image: #imageLiteral(resourceName: "Alien")) ] //transfer to a model
    
    var emojiCollection : BWCollectionView!
    
    override func didMove(to view: SKView) {
        emojiCollection = BWCollectionView(at: view)
        emojiCollection.dataSource = self
        
        emojiCollection.position = CGPoint(x: size.width*0.5,
                                           y: size.height*0.5)
        
        addChild(emojiCollection)
    }
    
    func numberOfItems() -> Int {
        return emojis.count
    }
    
    func collectionView(_ collection: BWCollectionView, itemFor index: Index) -> BWCollectionViewItem {
        let item = EmojiItem()
        item.emoji = emojis[index]
        return item
    }
    
    override func update(_ currentTime: TimeInterval) {
        emojiCollection.update(currentTime)
    }
}
