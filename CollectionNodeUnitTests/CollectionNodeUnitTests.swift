//
//  CollectionNodeUnitTests.swift
//  CollectionNodeUnitTests
//
//  Created by Bruno Fulber Wide on 04/10/17.
//  Copyright © 2017 BW. All rights reserved.
//

import XCTest
import SpriteKit

class CollectionNodeUnitTests: XCTestCase {
    
    var scene: MockGameScene!
    
    override func setUp() {
        super.setUp()
        
        scene = MockGameScene(size: UIScreen.main.bounds.size)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIndex() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let gameVC = GameViewController()
        
        
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
