//
//  MenuScene.swift
//  ThinkDifferent
//
//  Created by Omar Alejel on 3/31/15.
//  Copyright (c) 2015 omar alejel. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    //the current mode selected in the menu
    enum Mode: Int {
        case Single, Multiplayer, More
    }
    
    var selection: Mode = Mode.Single {
        didSet {
            if contentCreated {
                runAction(SKAction.playSoundFileNamed("scroll.caf", waitForCompletion: false))
                singleLabel.text = "Single"
                multiplayerLabel.text = "Multi"
                moreLabel.text = "More"
                switch selection {
                case .Single:
                    singleLabel.text = "Single <"
                case .Multiplayer:
                    multiplayerLabel.text = "Multi  <"
                case .More:
                    moreLabel.text = "More   <"
                }
            }
        }
    }
    //the box representing the tv
    var tvNode: SKSpriteNode!
    var remoteNode: SKSpriteNode!
    var remoteUpNode: SKSpriteNode!
    var remoteDownNode: SKSpriteNode!
    var remoteGoNode: SKSpriteNode!
    var characterNode: SKSpriteNode!
    
    //important labels
    var singleLabel: SKLabelNode!
    var multiplayerLabel: SKLabelNode!
    var moreLabel: SKLabelNode!
    
    //to tell if content was initialized
    var contentCreated = false
    
    //early setup - not drawing
    override init(size: CGSize) {
        super.init(size: size)
        
        //below must be in this order!!
        initTelevision()
        initRemote()
        initMenuLabels()
        initCharacter()
    }

    //ignore
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //initial drawing setup
    override func didMoveToView(view: SKView) {
        if !contentCreated {
            backgroundColor = UIColor.blackColor()
            
            //draw child nodes/subviews here
            addChild(tvNode)
            addChild(singleLabel)
            addChild(multiplayerLabel)
            addChild(moreLabel)
            addChild(remoteNode)
            addChild(characterNode)
            
            //try to get an ease in movement
            let remoteSeq = SKAction.sequence([SKAction.waitForDuration(2.0), SKAction.moveToY(0, duration: 0.8)])
            remoteNode.runAction(remoteSeq)
            
            let infoLabel = SKLabelNode(fontNamed: "Press Start")
            infoLabel.text = "© 2015 omar al-ejel"
            infoLabel.fontSize = 9
            infoLabel.position = CGPointMake(size.width - infoLabel.frame.size.width / 2, 0)
            addChild(infoLabel)
            
            
//            let bp = UIBezierPath()
//            bp.moveToPoint(CGPointMake(46, 12))
//            bp.addLineToPoint(CGPointMake(60, 25))
//            bp.addLineToPoint(CGPointMake(70, 2))
//            let l = CAShapeLayer()
//            l.path = bp.CGPath
//            l.strokeColor = SKColor.redColor().CGColor
//            l.lineWidth = 2
//            view.layer.addSublayer(l)
            
            contentCreated = true
        }
    }
    
    
    
    //MARK: Scene Setup functions
    
    func initMenuLabels() {
        let fontSize = fontSizeForDevice()
        let fontName = "Press Start"
        
        singleLabel = SKLabelNode(fontNamed: fontName)
        singleLabel.horizontalAlignmentMode = .Left
        singleLabel.text = "Single  <"//it will be the 1st selection, so put a marker
        singleLabel.color = SKColor.redColor()
        singleLabel.colorBlendFactor = 1
        singleLabel.fontSize = fontSize
        singleLabel.name = "single"
        
        
        multiplayerLabel = SKLabelNode(fontNamed: fontName)
        multiplayerLabel.horizontalAlignmentMode = .Left
        multiplayerLabel.text = "Multi"
        multiplayerLabel.color = SKColor.redColor()
        multiplayerLabel.colorBlendFactor = 1
        multiplayerLabel.fontSize = fontSize
        multiplayerLabel.name = "multiplayer"
        
        moreLabel = SKLabelNode(fontNamed: fontName)
        moreLabel.horizontalAlignmentMode = .Left
        moreLabel.text = "More"
        moreLabel.color = SKColor.redColor()
        moreLabel.colorBlendFactor = 1
        moreLabel.fontSize = fontSize
        moreLabel.name = "more"
        
        if tvNode != nil {
            let tvX = tvNode.frame.origin.x
            let tvY = tvNode.frame.origin.y
            let tvH = tvNode.frame.size.height
            //let tvW = tvNode.frame.size.width
            
            //labels have their anchor points at the bottom center
            let yOffset = (tvH / 3) + singleLabel.frame.size.height
            moreLabel.position = CGPointMake(8 + tvX, tvY + yOffset/2)
            multiplayerLabel.position = CGPointMake(8 + tvX, tvY + (yOffset * 2) / 2)
            singleLabel.position = CGPointMake(8 + tvX, tvY + (yOffset * 3) / 2)
         }
    }
    
    func initTelevision() {
        fontSizeForDevice()
        let tvOffset: CGFloat = 25;
        let tvWidth = size.width / 2
        let tvHeight = tvWidth / 1.2
        let tvSize = CGSizeMake(tvWidth, tvHeight)//adjust height proportion
        tvNode = SKSpriteNode(color: SKColor.redColor(), size: tvSize)
        tvNode.position = CGPointMake(size.width / 4, size.height - (tvOffset + (tvHeight / 2)))
        
        let childSize = CGSizeMake(tvWidth - 10, tvHeight - 10)
        let child = SKSpriteNode(color: SKColor.blackColor(), size: childSize)
        tvNode.addChild(child)
    }
    
    func initRemote() {
        if remoteNode == nil {
            let remoteWidth = size.width / 3
            let remoteHeight = size.height / 1.6
            remoteNode = SKSpriteNode(color: SKColor.greenColor(), size: CGSizeMake(remoteWidth, remoteHeight))
            remoteNode.position = CGPointMake(8 + (remoteNode.size.width / 2), -1 * remoteNode.size.height / 2)
            let childSize = CGSizeMake(remoteWidth - 5, remoteHeight - 5)
            let childNode = SKSpriteNode(color: SKColor.blackColor(), size: childSize)
            remoteNode.addChild(childNode)
            
            let fontName = "Press Start"
            let buttonWidth = remoteWidth / 1.2
            let buttonHeight = buttonWidth / 3.4
            let buttonSize = CGSizeMake(buttonWidth, buttonHeight)
            remoteUpNode = SKSpriteNode(color: SKColor.redColor(), size: buttonSize)
            remoteUpNode.position = CGPointMake(0, (remoteHeight / 2) - (15 + buttonHeight / 2))
            remoteNode.addChild(remoteUpNode)
            let upLabel = SKLabelNode(fontNamed: fontName)
            upLabel.text = "^"
            let fontSize: CGFloat = 20
            upLabel.fontSize = fontSize
            upLabel.position = CGPointMake(0, -10)
            remoteUpNode.addChild(upLabel)
            
            let goButtonSize = CGSizeMake(buttonSize.width / 1.4, buttonSize.width / 1.4)
            remoteGoNode = SKSpriteNode(color: SKColor.redColor(), size: goButtonSize)
            remoteGoNode.position = CGPointMake(0, remoteUpNode.position.y - (remoteGoNode.size.height / 1.3))
            remoteNode.addChild(remoteGoNode)
            let goLabel = SKLabelNode(fontNamed: fontName)
            goLabel.fontSize = fontSize
            goLabel.text = "go"
            remoteGoNode.addChild(goLabel)
            
            remoteDownNode = SKSpriteNode(color: SKColor.redColor(), size: buttonSize)
            remoteDownNode.position = CGPointMake(0, remoteGoNode.position.y - (remoteGoNode.size.height / 1.3))
            remoteNode.addChild(remoteDownNode)
            let downLabel = SKLabelNode(fontNamed: fontName)
            downLabel.fontSize = fontSize
            downLabel.text = "^"
            downLabel.position = CGPointMake(0, -10)
            remoteDownNode.addChild(downLabel)
            remoteDownNode.zRotation = CGFloat(M_PI)
        }
    }
    
    func initCharacter() {
        let standTexture = SKTexture(imageNamed: "ch1")
        let leftStepTexture = SKTexture(imageNamed: "ch2")
        let rightStepTexture = SKTexture(imageNamed: "ch3")
        
        let charHeight = size.height - (tvNode.size.height + 60)
        let charSize = CGSizeMake(charHeight * 0.468, charHeight)
        characterNode = SKSpriteNode(texture: rightStepTexture, size: charSize)
        characterNode.position = CGPointMake(size.width + characterNode.size.width / 2, charHeight / 2)
        
        let playStepSound = SKAction.playSoundFileNamed("step.caf", waitForCompletion: false)
        
        let wait = SKAction.waitForDuration(0.375)//change
        let rightStep = SKAction.sequence([SKAction.setTexture(rightStepTexture), playStepSound])
        let leftStep = SKAction.sequence([SKAction.setTexture(leftStepTexture), playStepSound])
        let stand = SKAction.setTexture(standTexture)
        let moveX = SKAction.moveToX(size.width - (characterNode.size.width), duration: 3.0)
        
        let interval = SKAction.sequence([wait, leftStep, wait, rightStep])
        let charSequence = SKAction.sequence([interval, interval, interval, interval, stand])
        let charFinalAction = SKAction.group([charSequence, moveX])
        characterNode.runAction(charFinalAction)
    }
    
    func fontSizeForDevice() -> CGFloat {
        //let idiom = UIDevice.currentDevice().userInterfaceIdiom
        return 15 
    }
    
    //this will give a recatngle specific to the device screen size
    func computedTvRect() {
        
    }
    
    //MARK: - User Interaction
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        let touch = touches.first
        let loc = touch!.locationInNode(self)
        if (CGRectContainsPoint(singleLabel.frame, loc)) {
            print("single")
            selection = .Single
        } else if CGRectContainsPoint(multiplayerLabel.frame, loc) {
            print("multi")
            selection = .Multiplayer
        } else if CGRectContainsPoint(moreLabel.frame, loc) {
            print("more")
            selection = .More
        } else {
            let loc = touch!.locationInNode(remoteNode)
            if CGRectContainsPoint(remoteUpNode.frame, loc) {
                print("up")
                var raw = selection.rawValue
                if raw == 0 {
                    raw = 2
                } else {
                    raw -= 1
                }
                selection = Mode(rawValue: raw)!
            } else if CGRectContainsPoint(remoteDownNode.frame, loc) {
                print("down")
                var raw = selection.rawValue
                if raw == 2 {
                    raw = 0
                } else {
                    raw + 1
                }
                selection = Mode(rawValue: raw)!
            } else if CGRectContainsPoint(remoteGoNode.frame, loc) {
                runAction(SKAction.playSoundFileNamed("select.caf", waitForCompletion: false))
                print("go")
                //do something based on the current selection
                //move down
                let hideRemote = SKAction.moveToY(-1 * remoteNode.size.height / 2, duration: 0.25)
                
                switch selection {
                case .Single:
                    remoteNode.runAction(hideRemote, completion: { () -> Void in
                        self.transitionToSingleMode()
                    })
                default:
                    break
                }
                
                
            }
        }

    }
    
    //MARK: Transitions to game
    
    func transitionToSingleMode() {
        print("transitioning to single player")
        let singleModeScene = SinglePlayerScene(size: size)
        view?.presentScene(singleModeScene, transition: SKTransition.fadeWithDuration(1.0))
    }
    
}
