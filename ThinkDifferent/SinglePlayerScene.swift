//
//  SinglePlayerScene.swift
//  ThinkDifferent
//
//  Created by Omar Alejel on 3/20/15.
//  Copyright (c) 2015 omar alejel. All rights reserved.
//

import Foundation
import SpriteKit

class GameBlock: SKSpriteNode {
    enum BlockType: Int {
        case Normal, Slow, Fast, Tilt
    }
    
    //bloacktype describes the block/s powerup/down if it has any
    var blockType = BlockType.Normal {
        didSet {
            switch (blockType) {
            case .Normal:
                break
            case .Slow:
                color = SKColor.blueColor()
                break
            case .Fast:
                color = SKColor.orangeColor()
                break
            case .Tilt:
                color = UIColor.greenColor()
                break
            }
            
            if blockType != .Normal {
                let fadeOut = SKAction.fadeAlphaTo(0.1, duration: 0.7)
                let fadeIn = SKAction.fadeAlphaTo(1, duration: 0.7)
                let sequence = SKAction.sequence([fadeOut, fadeIn])
                let infinite = SKAction.repeatActionForever(sequence)
                runAction(infinite)
            }
        }
        
    }
    
    func randomPowerup() {
        let randomRaw = 1 + (random() % 3)
        blockType = BlockType(rawValue: randomRaw)!
    }
}

class SinglePlayerScene: SKScene, SKPhysicsContactDelegate {
    
    //visual
    
    
    var freezeOn = false
    var playerNode: SKSpriteNode!
    var subPlayerNode: SKSpriteNode!
    
    var gameField: SKSpriteNode!
    var outlineNode: SKCropNode!
    
    //logic
    
    var playing: Bool = true
    
    var generationDelay: Double = 0.23
    
    
    var blockFallDuration = 5.0
    var fallDurationStandard = 5.0
    
    var blocks: [GameBlock] = []
    
    var generationAction: SKAction!
    
    var lastTime: NSTimeInterval = 0
    var blockSize: CGSize!
    
    //interaction
    
    var touchStart: CGPoint!
    var lastX: CGFloat!
    var lastY: CGFloat!
    
    var newPowerupCounter = 0
    let newPowerupConstant = 20//every 20 blocks...
    
    //Making it fun
    var score = 0
    enum GameEvent {
        case Fast, Slow, Slanted, Gyro
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        blockFallDuration = Double(size.height) * 0.012
        fallDurationStandard = blockFallDuration
        let bwh = 0.042 * size.width // a nice ratio with the scree width
        blockSize = CGSizeMake(bwh, bwh)
        
        let outlineWidth = size.width
        let outlineHeight = size.height
        outlineNode = SKCropNode()
        outlineNode.position = CGPointMake(size.width / 2, size.height - outlineHeight / 2)
        outlineNode.maskNode = SKSpriteNode(color: SKColor.blackColor(), size: CGSizeMake(outlineWidth - 4, outlineHeight - 4))
    
        gameField = SKSpriteNode(color: SKColor.blackColor(), size: CGSizeMake(outlineWidth, outlineHeight))
        gameField.position = CGPointMake(0, 0)
        outlineNode.addChild(gameField)
        //outlineNode added later
        let extra = SKSpriteNode(color: SKColor.redColor(), size: CGSizeMake(outlineWidth, outlineHeight))
        extra.position = CGPointMake(size.width / 2, size.height - outlineHeight / 2)
        addChild(extra)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        backgroundColor = SKColor.blackColor()
        addChild(outlineNode)
        drawPlayer()
        startGeneration()
        runAction(SKAction())
    }
    
    //MARK: - Drawing Functions
    
    func startGeneration() {
        let blockAction = SKAction.runBlock { () -> Void in
            self.addBlock()
        }
        let delay = SKAction.waitForDuration(generationDelay)
        let sequence = SKAction.sequence([blockAction, delay])
        generationAction = SKAction.repeatActionForever(sequence)
        runAction(generationAction)
    }
    
    func drawPlayer() {
        if (playerNode == nil) {
            //set outline color (the node itself) and a dark blue as a child node
            let outColor = SKColor(red: 0.047, green: 0.78, blue: 1.0, alpha: 1.0)
            let inColor = SKColor(red: 0.047, green: 0.509, blue: 0.9, alpha: 1.0)
            let wh = 0.0378 * size.width
            playerNode = SKSpriteNode(color: outColor, size: CGSizeMake(wh, wh))
            let childSize = CGSizeMake(playerNode.size.width * 0.9, playerNode.size.height * 0.9)
            subPlayerNode = SKSpriteNode(color: inColor, size: childSize)
            playerNode.addChild(subPlayerNode)
            playerNode.position = CGPointMake(0, 0)
            
            gameField.addChild(playerNode)
        }
    }
    
    func addBlock() {
        //get random x value
        let arcRand = Int(arc4random_uniform(10000))
        let x = Int(size.width / 2) - (Int(arcRand) % Int(size.width))
        let newBlock = GameBlock(color: SKColor.whiteColor(), size: blockSize)
        newBlock.position = CGPointMake(CGFloat(x), gameField.size.height / 2)
        //give it a dropping action
        newBlock.runAction(SKAction.moveToY((gameField.size.height * -0.5) - 5 - newBlock.size.height / 2, duration: blockFallDuration))
        
        if newPowerupCounter == newPowerupConstant {
            newBlock.randomPowerup()
            newPowerupCounter = 0
        }
        
        blocks.append(newBlock)
        gameField.addChild(newBlock)
        
        //for new powerups
        newPowerupCounter++
    }
    
    func randomPower() {

    }
    
    override func didSimulatePhysics() {
        super.didSimulatePhysics()
        if playing {
            reactToCollisions()
        }
    }
    
    //MARK: Logic
    
    func removeBlockNodeWithIndex(block: SKSpriteNode, index: Int) {
        blocks.removeAtIndex(index)
        block.removeFromParent()
        block.removeAllActions()
        score++
    }
    
    func reactToCollisions() {
        let px = playerNode.position.x
        let py = playerNode.position.y
        let pw = playerNode.size.width
        let ph = playerNode.size.height
        
        if px + pw / 2 >= gameField.size.width / 2 {
            print("1")
            lose()
        } else if px - pw / 2 <= -1 * gameField.size.width / 2 {
            print("2")
            lose()
        } else if py + ph / 2 >= gameField.size.height / 2 {
            print("3")
            lose()
        } else if py - ph / 2 <= -1 * gameField.size.height / 2 {
            print("4")
            lose()
        }
        
        for (index, block) in self.blocks.enumerate() {
            var collided = false
            
            if CGRectIntersectsRect(playerNode.frame, block.frame) {
                collided = true
            }
            
            if collided {
                //test if special!!!
                if block.blockType != .Normal {
                    
                    switch (block.blockType) {
                    case .Normal:
                        break
                    case .Slow:
                        if blockFallDuration < fallDurationStandard {
                            blockFallDuration *= 1.4
                        }
                        break
                    case .Fast:
                        blockFallDuration /= 1.4
                        break
                    case .Tilt:
                        for b in blocks {
                            if freezeOn {
                                if b.blockType == .Tilt {
                                    removeBlockNodeWithIndex(block, index: index)
                                }
                                freezeOn = false
                            } else {
                                if b.blockType == .Normal {
                                    b.removeAllActions()
                                    b.color = SKColor.grayColor()
                                }
                                freezeOn = true
                            }
                        }
                        break
                    }
                    
                    removeBlockNodeWithIndex(block, index: index)
                    return//so that we dont make the block bigger
                }
                
                runAction(SKAction.playSoundFileNamed("bump.caf", waitForCompletion: false))
                print("-----collided-_-_-_-_-_-")
                removeBlockNodeWithIndex(block, index: index)
                expandPlayer()
            } else if block.position.y <= (gameField.size.height * -0.5) - 5 - block.size.height / 2 {
                print("removing block")
                removeBlockNodeWithIndex(block, index: index)
            }
        }
    }
    
    func expandPlayer() {
        //scaling bight be better than this
        subPlayerNode.runAction(SKAction.resizeByWidth(7, height: 7, duration: 0.0))
        playerNode.runAction(SKAction.resizeByWidth(7, height: 7, duration: 0.0))
        
        generationDelay += 0.04
    }
    
    //MARK: change in game flow
    
    func lose() {
        print("game end")
        playing = false
        //pause all actions
        removeAllActions()
        for block: SKSpriteNode in blocks {
            block.runAction(SKAction.scaleTo(0, duration: 2.0))
        }
        runAction(SKAction.playSoundFileNamed("crash.caf", waitForCompletion: false))
    }
    
    //MARK: Drawing Initializers
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if playing{
            touchStart = touches.first?.locationInNode(self)
            lastX = touchStart.x
            lastY = touchStart.y
            //        let offsetX = playerNode.position.x + touchStart.x
            //        let offsetY = playerNode.position.y + touchStart.y
            //touchDistance = sqrt(pow(touchStart.x - playerNode.position.x, 2) + pow(touchStart.y - playerNode.position.y, 2))
        } else {
            view?.presentScene(NewMenuScene(size: size), transition: SKTransition.fadeWithDuration(1.0))
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if playing {
            let touch = touches.first
            let fingerLocation = touch!.locationInNode(self)
            let newX = fingerLocation.x
            let newY = fingerLocation.y
            
            let offsetX = newX - lastX
            let offsetY = newY - lastY
            let vector = CGVectorMake(offsetX, offsetY)
            playerNode.runAction(SKAction.moveBy(vector, duration: 0))
            
            lastX = newX
            lastY = newY
        }
    }
    
    
}
