//
//  emojiItem.swift
//  SKCollectionViewExample
//
//  Created by Bruno Fulber Wide on 31/07/17.
//  Copyright © 2017 BW. All rights reserved.
//

import Foundation
import SpriteKit

class EmojiItem : CollectionNodeItem {
    private var nameLabel : SKLabelNode = SKLabelNode()
    private var imageNode : SKSpriteNode!
    
    var emoji : Emoji! {
        didSet{
            nameLabel.text = emoji.name
            imageNode = SKSpriteNode(texture: SKTexture(image: emoji.image))
            
            nameLabel.position.y += 80
            
            addChild(nameLabel)
            addChild(imageNode)
        }
    }
}
