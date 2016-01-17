//
//  SinglePlayerScene.swift
//  ThinkDifferent
//
//  Created by Omar Alejel on 3/20/15.
//  Copyright (c) 2015 omar alejel. All rights reserved.
//

import Foundation
import SpriteKit

class SinglePlayerScene: SKScene, SKPhysicsContactDelegate {
    
    var playing: Bool = true
    
    var generationDelay: Double = 0.23
    var blockFallDuration = 5.0

    var blocks: [SKSpriteNode] = []
    
    var playerNode: SKSpriteNode!
    var subPlayerNode: SKSpriteNode!
    
    var gameField: SKSpriteNode!
    var outlineNode: SKCropNode!
    
    
    var joystick: Joystick!
    
    var generationAction: SKAction!
    
    var score = 0
    
    var lastTime: NSTimeInterval = 0
    var blockSize: CGSize!
    
    override init(size: CGSize) {
        super.init(size: size)
        
        blockFallDuration = Double(size.height) * 0.017
        let bwh = 0.042 * size.width // a nice ratio with the scree width
        blockSize = CGSizeMake(bwh, bwh)
        
        let outlineWidth = size.width
        let outlineHeight = size.height - 100
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
        //draw the player and begin the block generation loop
        drawController()
        drawPlayer()
        startGeneration()
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
        //draw/ update player
        if (playerNode == nil) {
            //set outline color (the node itself) and a dark blue as a child node
            let outColor = SKColor(red: 0.047, green: 0.78, blue: 1.0, alpha: 1.0)
            let inColor = SKColor(red: 0.047, green: 0.509, blue: 0.9, alpha: 1.0)
            let wh = 0.0378 * size.width
            playerNode = SKSpriteNode(color: outColor, size: CGSizeMake(wh, wh))
            let childSize = CGSizeMake(playerNode.size.width - 2, playerNode.size.height - 2)
            subPlayerNode = SKSpriteNode(color: inColor, size: childSize)
            playerNode.addChild(subPlayerNode)
            //set position
            playerNode.position = CGPointMake(0, 0)
            
            gameField.addChild(playerNode)
        }
    }
    
    func addBlock() {
        //get random x value
        let arcRand = Int(arc4random_uniform(10000))
        let x = Int(size.width / 2) - (Int(arcRand) % Int(size.width))
        let newBlock = SKSpriteNode(color: SKColor.whiteColor(), size: blockSize)
        newBlock.position = CGPointMake(CGFloat(x), gameField.size.height / 2)
        //give it a dropping action
        newBlock.runAction(SKAction.moveToY((gameField.size.height * -0.5) - 5 - newBlock.size.height / 2, duration: blockFallDuration))
        
        blocks.append(newBlock)
        gameField.addChild(newBlock)
    }
    
    override func didSimulatePhysics() {
        super.didSimulatePhysics()
        if playing {
            reactToCollisions()
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        if playing {
            //see if joystick is moving
            if joystick.velocity.x != 0 || joystick.velocity.y != 0 {
                if lastTime == 0 {
                    lastTime = currentTime
                }
                let delta = (CGFloat(currentTime - lastTime) + 1) / 12
                lastTime = currentTime
                
                let vx = joystick.velocity.x * delta
                let vy = joystick.velocity.y * delta
//                let vector = CGVector(dx: vx, dy: vy)
//                playerNode.physicsBody?.applyForce(vector)
                playerNode.position.x += vx
                playerNode.position.y += vy
            }
        }
    }
    
    //MARK: Logic
    
    func removeBlockNodeWithIndex(block: SKSpriteNode, index: Int){
        block.removeFromParent()
        blocks.removeAtIndex(index)
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
                print("-----collided------")
                removeBlockNodeWithIndex(block, index: index)
                expandPlayer();
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
    }
    
    //MARK: Drawing Initializers
    
    func drawController() {
        let backNode = SKSpriteNode(imageNamed: "backdrop.png")
        let height: CGFloat = 100
        backNode.size = CGSizeMake(height, height)
        let thumbNode = SKSpriteNode(imageNamed: "thumb.png")
        thumbNode.size = CGSizeMake(height / 1.8, height / 1.8)
        joystick = Joystick(thumb: thumbNode, andBackdrop: backNode)
        
        joystick.position = CGPointMake(size.width - height / 2, height / 2)
        addChild(joystick)
    }
}
