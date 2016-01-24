//
//  SoundManager.swift
//  Blizzard
//
//  Created by Omar Alejel on 1/23/16.
//  Copyright © 2016 omar alejel. All rights reserved.
//

import UIKit
import AVFoundation

class SoundManager: NSObject {
    var blizzardPlayer: AVAudioPlayer!
    
    override init() {
        super.init()
        
        let blizzardPath = NSBundle.mainBundle().pathForResource("blizzsound", ofType: "aiff")
        let blizzardURL = NSURL(fileURLWithPath: blizzardPath!)
        blizzardPlayer = try! AVAudioPlayer(contentsOfURL: blizzardURL, fileTypeHint: "aiff")
        blizzardPlayer.numberOfLoops = -1//play indefinitely
        blizzardPlayer.prepareToPlay()
    }
    
    func startBlizzardSound() {
        blizzardPlayer.play()
    }
    
    func stopBlizzardSound() {
        
    }
    
}
