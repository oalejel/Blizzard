//
//  NewMenuScene.swift
//  Blizzard
//
//  Created by Omar Alejel on 1/24/16.
//  Copyright © 2016 omar alejel. All rights reserved.
//

import UIKit

class NewMenuScene: SKScene {
    //the current mode selected in the menu
    enum Mode: Int {
        case Single, Multiplayer, More
    }
//    
//
//    //important labels
//    var singleLabel: SKLabelNode!
//    var multiplayerLabel: SKLabelNode!
//    var moreLabel: SKLabelNode!
    
    //to tell if content was initialized
    var contentCreated = false
    
    var playerNode: SKSpriteNode!
    var subPlayerNode: SKSpriteNode!
    
    var generationDelay: Double = 0.23
    var blockFallDuration = 5.0
    var blockSize: CGSize!
    var blocks: [SKSpriteNode] = []
    
    var generationAction: SKAction!
    
    //early setup - not drawing
    override init(size: CGSize) {
        super.init(size: size)
        blockFallDuration = Double(size.height) * 0.017
        let bwh = 0.042 * size.width // a nice ratio with the scree width
        blockSize = CGSizeMake(bwh, bwh)
    }
    
    //ignore
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func drawPlayer() {
        //draw/ update player
        if (playerNode == nil) {
            //set outline color (the node itself) and a dark blue as a child node
            let outColor = SKColor(red: 0.047, green: 0.78, blue: 1.0, alpha: 1.0)
            let inColor = SKColor(red: 0.047, green: 0.509, blue: 0.9, alpha: 1.0)
            let wh = 0.5 * size.width
            playerNode = SKSpriteNode(color: outColor, size: CGSizeMake(wh, wh))
            let childSize = CGSizeMake(playerNode.size.width * 0.9, playerNode.size.height * 0.9)
            subPlayerNode = SKSpriteNode(color: inColor, size: childSize)
            playerNode.addChild(subPlayerNode)
            //set position
            let bounds = UIScreen.mainScreen().bounds
            playerNode.position = CGPointMake(bounds.size.width / 2, bounds.size.height / 2)
            
            addChild(playerNode)
        }
    }
    
    //initial drawing setup
    override func didMoveToView(view: SKView) {
        if !contentCreated {
            backgroundColor = UIColor.blackColor()
            
            drawPlayer()
            startGeneration()
            
            contentCreated = true
            
            let bounds = UIScreen.mainScreen().bounds
            let boxWidth = bounds.size.width / 2.5
            let boxHeight = boxWidth / 2.5
            let titleNode = SKShapeNode(rect: CGRectMake(0, 0, boxWidth, boxHeight), cornerRadius: boxWidth / 20)
            titleNode.fillColor = SKColor.redColor()
            titleNode.position = CGPointMake((bounds.size.width / 2) - (boxWidth / 2), (playerNode.frame.origin.y - (boxHeight * 1.5)))
            addChild(titleNode)
        }
    }
    
    func addBlock() {
        //get random x value
        let arcRand = Int(arc4random_uniform(10000))
        let x = Int(size.width) - (Int(arcRand) % Int(size.width))
        let newBlock = SKSpriteNode(color: SKColor.whiteColor(), size: blockSize)
        newBlock.position = CGPointMake(CGFloat(x), size.height)
        //give it a dropping action
        newBlock.runAction(SKAction.moveToY((size.height * -0.5) - 5 - newBlock.size.height / 2, duration: blockFallDuration))
        
        blocks.append(newBlock)
        addChild(newBlock)
        newBlock.zPosition = -1
    }
    
    override func didSimulatePhysics() {
        super.didSimulatePhysics()
        for (index, block) in blocks.enumerate() {
            if block.position.y <= (size.height * -0.5) - 5 - block.size.height / 2 {
                print("removing block")
                removeBlockNodeWithIndex(block, index: index)
            }
        }
    }
    
    func removeBlockNodeWithIndex(block: SKSpriteNode, index: Int) {
        blocks.removeAtIndex(index)
        block.removeFromParent()
        block.removeAllActions()
    }
    
    func startGeneration() {
        let blockAction = SKAction.runBlock { () -> Void in
            self.addBlock()
        }
        let delay = SKAction.waitForDuration(generationDelay)
        let sequence = SKAction.sequence([blockAction, delay])
        generationAction = SKAction.repeatActionForever(sequence)
        runAction(generationAction)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        transitionToSingleMode()
    }
    
    //MARK: Transitions to game
    
    func transitionToSingleMode() {
        print("transitioning to single player")
        let singleModeScene = SinglePlayerScene(size: size)
        view?.presentScene(singleModeScene, transition: SKTransition.fadeWithDuration(1.0))
    }
    
}
