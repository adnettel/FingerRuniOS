//
//  Button.swift
//  FingerRun
//
//  Created by Adam Nettel on 7/26/15.
//  Copyright (c) 2015 AdamDev. All rights reserved.
//

import Foundation
import SpriteKit

class Button: SKNode {
    
    var size: CGSize = CGSize.zero
    var text: String = ""
    var fontSize: CGFloat!
    var outline: SKShapeNode!
    var buttonPressed = false
    let textLabel = SKLabelNode(fontNamed: "Edit Undo Line BRK")

    
    init(size: CGSize, text: String, name: String, fontSize: CGFloat) {
        self.size = size
        self.text = text
        self.fontSize = fontSize
        super.init()
        self.name = name
        
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setUp() {
        
        outline = SKShapeNode(rectOf: size)
        outline.fillColor = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
        outline.strokeColor = SKColor.white
        outline.lineWidth = 5
        
        textLabel.text = self.text
        textLabel.fontColor = SKColor.white
        textLabel.fontSize = fontSize
        textLabel.verticalAlignmentMode = .center
        
        outline.addChild(textLabel)
        addChild(outline)
        
    }
    
    func buttonTouched() {
        buttonPressed = true
        outline.fillColor = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1)
    }
    
    func buttonCancelled() {
        buttonPressed = false
        outline.fillColor = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
    }
    
    func setLabelText(_ t: String) {
        textLabel.text = t
    }
    
}
