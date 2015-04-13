//
//  ViewController.swift
//  ThinkDifferent
//
//  Created by Omar Alejel on 3/20/15.
//  Copyright (c) 2015 omar alejel. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let skView = view as! SKView
//        let scene = MenuScene(size: skView.frame.size)
        let scene = SinglePlayerScene(size: skView.frame.size)
        scene.size = view.frame.size
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
        skView.showsFPS = true
        skView.showsDrawCount = true
        skView.showsNodeCount = true
    }
    
}

