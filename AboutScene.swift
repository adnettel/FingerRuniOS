//
//  AboutScene.swift
//  FingerRun
//
//  Created by Adam Nettel on 7/30/15.
//  Copyright (c) 2015 AdamDev. All rights reserved.
//

import Foundation
import SpriteKit

class AboutScene: SKScene {
    
    let playableRect: CGRect!
    
    var backButton: Button!
    
    
    override init(size: CGSize) {
        
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let playableMargin = (size.width-playableWidth)/2.0
        playableRect = CGRect(x: playableMargin, y: 0,
            width: playableWidth,
            height: size.height)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
        
        setUpUI()
        
        
    }
    
    override func touchesBegan(_ touches: Set<NSObject>, with event: UIEvent) {
        let touch = touches.first as! UITouch
        
        if backButton.contains(touch.location(in: self)) {
            backButton.buttonTouched()
        }
        
    }
    
    override func touchesMoved(_ touches: Set<NSObject>, with event: UIEvent) {
        let touch = touches.first as! UITouch
        
        // Checks if the button was pressed and the finger slid off of the button
        
        if backButton.buttonPressed && !backButton.contains(touch.location(in: self)) {
            backButton.buttonCancelled()
        }
        
    }
    
    override func touchesEnded(_ touches: Set<NSObject>, with event: UIEvent) {
        let touch = touches.first as! UITouch
        
        // Button clicked
        
        if backButton.buttonPressed && backButton.contains(touch.location(in: self)) {
            mainMenu()
        }
    }
    
    func setUpUI() {
        
        let aboutLabel = SKLabelNode(fontNamed: "Edit Undo Line BRK")
        aboutLabel.fontSize = 150
        aboutLabel.text = "HELP"
        aboutLabel.position = CGPoint(x: size.width/2, y: size.height * 0.83)
        aboutLabel.fontColor = SKColor.white
        addChild(aboutLabel)
        
        let about1 = SKLabelNode(fontNamed: "Edit Undo Line BRK")
        about1.fontSize = 80
        about1.text = "Dodge the bars as"
        about1.position = CGPoint(x: size.width/2, y: size.height * 0.6)
        about1.fontColor = SKColor.white
        addChild(about1)
        
        let about2 = SKLabelNode(fontNamed: "Edit Undo Line BRK")
        about2.fontSize = 80
        about2.text = "they fall from the"
        about2.position = CGPoint(x: size.width/2, y: size.height * 0.56)
        about2.fontColor = SKColor.white
        addChild(about2)
        
        let about3 = SKLabelNode(fontNamed: "Edit Undo Line BRK")
        about3.fontSize = 80
        about3.text = "top of the screen"
        about3.position = CGPoint(x: size.width/2, y: size.height * 0.52)
        about3.fontColor = SKColor.white
        addChild(about3)
        
        backButton = Button(
            size: CGSize(
                width: playableRect.width * 0.75,
                height: playableRect.height * 0.1),
            text: "BACK",
            name: "backButton",
            fontSize: 100)
        backButton.position = CGPoint(x: size.width/2, y: size.height * 0.2)
        addChild(backButton)
        
    }
    
    func mainMenu() {
        let menuScene = MainMenuScene(size: size)
        menuScene.scaleMode = scaleMode
        
        let reveal = SKTransition.doorsCloseHorizontal(withDuration: 0.60)
        
        view?.presentScene(menuScene, transition: reveal)
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
