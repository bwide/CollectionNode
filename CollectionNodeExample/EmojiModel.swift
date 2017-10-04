//
//  EmojiModel.swift
//  BWCollectionViewExample
//
//  Created by Bruno Fulber Wide on 05/08/17.
//  Copyright © 2017 BW. All rights reserved.
//

import Foundation
public class EmojiModel {
    static var `default` : EmojiModel = EmojiModel()
    
    let emojis = [ Emoji("Heart Face", image: #imageLiteral(resourceName: "HeartFace")),
                   Emoji("Smiley Face", image: #imageLiteral(resourceName: "SmileyFace")),
                   Emoji("Space Invader", image: #imageLiteral(resourceName: "SpaceInvader")),
                   Emoji("Alien", image: #imageLiteral(resourceName: "Alien")) ]
    
    private init(){
        
    }
}
