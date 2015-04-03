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
    
    var start: Bool = true
    
    var cycles: Double = 0
    var generationDelay = 0.5
    var duration = 4.0
    var generationLimit = 10.0

    var blocks: [SKSpriteNode] = []
    
    var playerNode: SKSpriteNode!
    var subPlayerNode: SKSpriteNode!
    
    var gameField: SKSpriteNode!
    
    var up = false
    var down = false
    var right = false
    var left = false
    
    var generationAction: SKAction!
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        backgroundColor = SKColor.blackColor()
        let outlineWidth = size.width
        let outlineHeight = size.height - 100
        let outline = SKSpriteNode(color: SKColor.redColor(), size: CGSizeMake(outlineWidth, outlineHeight))
        outline.position = CGPointMake(size.width / 2, size.height - outline.size.height / 2)
        addChild(outline)
        gameField = SKSpriteNode(color: SKColor.blackColor(), size: CGSizeMake(outlineWidth - 4, outlineHeight - 3))
        gameField.position = CGPointMake(0, 0)
        outline.addChild(gameField)
        
        //draw the player and begin the block generation loop
        drawPlayer()
        startGeneration()
    }
    
    //MARK: - Drawing Functions
    
    ///////////////////////////Main loop below/////////////////////////////
    
    func startGeneration() {
        let blockAction = SKAction.runBlock { () -> Void in
            self.addBlock()
        }
        let delay = SKAction.waitForDuration(generationDelay)
        let sequence = SKAction.sequence([blockAction, delay])
        generationAction = SKAction.repeatActionForever(sequence)
        runAction(generationAction)
    }
    
    ///////////////////////////Main loop above/////////////////////////////
    
    func drawPlayer() {
        //draw/ update player
        if (playerNode == nil) {
            //set outline color (the node itself) and a dark blue as a child node
            let outColor = SKColor(red: 0.047, green: 0.78, blue: 1.0, alpha: 1.0)
            let inColor = SKColor(red: 0.047, green: 0.509, blue: 0.9, alpha: 1.0)
            playerNode = SKSpriteNode(color: outColor, size: CGSizeMake(18, 18))
            let childSize = CGSizeMake(playerNode.size.width - 2, playerNode.size.height - 2)
            subPlayerNode = SKSpriteNode(color: inColor, size: childSize)
            playerNode.addChild(subPlayerNode)

            
            //set position
            playerNode.position = CGPointMake(gameField.size.width / 2, (gameField.size.height / 2) + 50)
            
            gameField.addChild(playerNode)
        }
    }
    
    func addBlock() {
        //get random x value
        let arcRand = Int(arc4random_uniform(10000))
        let r = Int(arcRand + 2) % (Int(size.width) - 2)//CGFloat((Int(abs(arc4random_uniform(1000))) + 2) % Int(size.width - 2))
        let newBlock = SKSpriteNode(color: SKColor.whiteColor(), size: CGSizeMake(20, 20))
        newBlock.position = CGPointMake(CGFloat(r), size.height + 20)
        
        //give it a dropping action
        newBlock.runAction(SKAction.moveToY(-10, duration: duration))
        
        blocks.append(newBlock)
        gameField.addChild(newBlock)
    }
    
    override func didSimulatePhysics() {
        super.didSimulatePhysics()
        if start {
            reactToCollisions()
        }
    }
    
    //MARK: Logic
    
    func removeBlockNodeWithIndex(block: SKNode, index: Int){
        block.removeFromParent()
        blocks.removeAtIndex(index)
    }
    
    func reactToCollisions() {
        var p_width = playerNode.size.width
        var p_x = playerNode.position.x - p_width
        var p_y = playerNode.position.y + p_width
        
        for (index, block) in enumerate(self.blocks) {
            var collided = false
            
            if CGRectIntersectsRect(playerNode.frame, block.frame) {
                collided = true
            }
            
            if collided {
                println("-----collided------")
                removeBlockNodeWithIndex(block, index: index)
                expandPlayer();
            } else if (block.position.y < 0) {
                removeBlockNodeWithIndex(block, index: index)
            }

        }
    }
    
    func expandPlayer() {
        subPlayerNode.runAction(SKAction.resizeByWidth(10, height: 10, duration: 0.0))
        playerNode.runAction(SKAction.resizeByWidth(10, height: 10, duration: 0.0))
        
        generationDelay += 0.5
    }
}

/*

int x_max = 238;
int y_max = 318;

Double cycles = 0d; //how many cycles since a certain period

ArrayList<Integer> x_blocks = new ArrayList<Integer>(100);
ArrayList<Integer> y_blocks = new ArrayList<Integer>(100);
int num_blocks = 0;



int p_x = x_max / 2;
int p_y = y_max / 2;
int p_width = 9;//

Boolean u = false;
Boolean d = false;
Boolean r = false;
Boolean l = false;

void setup() {
    size(240, 320);
    drawEnvironment();
    
    createPlayer();
}

//as the difficulty increases, increase drop speed
void draw() {
    //check for collisons and in-bound-ness at end of function
    if (!inBounds()) {
        println("game end");
        fill(255, 60, 60);
        text("Game Over!", 90, 157);
        String out = "Score: " + cycles;
        text(out, 90, 169);
        return;
    }
    println(cycles);
    
    //if there was a collision, do what u got to do
    collided();
    
    //make the 10 random so not all fall in lines
    int cycleLimit = (int)(p_width - sqrt(p_width - 9));
    if (cycles % cycleLimit == 0) {
        newBlock();
    }
    
    for (int i = 0; i < num_blocks; i++) {
        //stupid java, not very elegant
        y_blocks.set(i, y_blocks.get(i) + 1);//increase y pos by 1
    }
    
    if (u || d || r || l) {
        editPlayerForInput();
    }
    
    drawEnvironment();
    updateBlocks();
    updatePlayer();
    
    cycles += 1;
    //delay(2);//changing this will decrease the chance of getting input :(
}

void editPlayerForInput() {
    if (u) {
        p_y--;
    }
    if (d) {
        p_y++;
    }
    if (r) {
        p_x++;
    }
    if (l) {
        p_x--;
    }
}

void keyPressed() {
    setKey(keyCode, true);
    if (key == 'q') {
        expandPlayer();
    }
}

void expandPlayer() {
    p_x -= 5;
    p_y -= 5;
    p_width += 7;
}

void keyReleased() {
    setKey(keyCode, false);
}

void setKey(int k, Boolean on) {
    if (k == UP) {
        u = on;
    }
    if (k == DOWN) {
        d = on;
    }
    if (k == RIGHT) {
        r = on;
    }
    if (k == LEFT) {
        l = on;
    }
}

void updatePlayer() {
    stroke(12, 200, 255);
    fill(12, 130, 230);
    rect(p_x, p_y, p_width, p_width);
}

void createPlayer() {
    stroke(12, 200, 255);
    fill(12, 130, 230);
    rect(p_x, p_y, p_width, p_width);
}

void drawEnvironment() {
    background(0);
    
    stroke(255, 0, 0);
    fill(0, 0, 0, 0);
    rect(0, 0, 239, 319);
    
    fill(255, 60, 60);
    String str = cycles.toString();
    String out = "Score: " + str;
    text(out, 2, 317);
}

void updateBlocks() {
    stroke(255);
    fill(255);
    for (int i = 0; i < num_blocks; i++) {
        int x = x_blocks.get(i);
        int y = y_blocks.get(i);
        if (y == y_max + 2) {
            //remove from y bkac
            //y_block
            println("removing block...");
            removeBlockAtIndex(i);
        } else {
            rect(x, y, 10, 10);
        }
    }
}

void removeBlockAtIndex(int index) {
    y_blocks.remove(index);
    x_blocks.remove(index);
    num_blocks--;
}

void newBlock() {
    //random x for block
    float r = 1.0 + random(228);
    stroke(255);
    fill(255);
    rect(r, 1, 10, 10);
    //add to an array
    num_blocks++;
    x_blocks.add(int(r));//give x position (since all other is given)
    y_blocks.add(1);//default y value at drop start
}

void collided() {
    Boolean top;
    Boolean bottom;
    Boolean right;
    Boolean left;
    
    for (int i = 0; i < num_blocks; i++) {
        int testx = x_blocks.get(i);
        int testy = y_blocks.get(i);
        
        if (p_x + p_width == testx) {//right side to left
            if (p_y - (testy + 10) <= 0 && testy - (p_y + p_width) <= 0) {
                expandPlayer();
                removeBlockAtIndex(i);
            }
        } else if (p_x == testx + 10) {//left to right
            if (p_y - (testy + 10) <= 0 && testy - (p_y + p_width) <= 0) {
                expandPlayer();
                removeBlockAtIndex(i);
            }
        } else if (p_y == testy + 10) {//top to bottom
            if (p_x - (testx + 10) <= 0 && testx - (p_x + p_width) <= 0) {
                expandPlayer();
                removeBlockAtIndex(i);
            }
        } else if (p_y + p_width == testy) {//bottom to top
            if (p_x - (testx + 10) <= 0 && testx - (p_x + p_width) <= 0) {
                expandPlayer();
                removeBlockAtIndex(i);
            }
        }
    }
}

Boolean inBounds() {
    if (p_x <= 1) {
        return false;
    }
    if (p_y <= 1) {
        return false;
    }
    if (p_x + p_width >= x_max) {
        return false;
    }
    if (p_y + p_width >= y_max) {
        return false;
    }
    
    return true;
}
*/

