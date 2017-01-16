//
//  MainMenuScene.swift
//  FingerRun
//
//  Created by Adam Nettel on 7/27/15.
//  Copyright (c) 2015 AdamDev. All rights reserved.
//

import SpriteKit

class MainMenuScene: SKScene {
    
    var gapWidthMultiplier: CGFloat = 2/5
    var rectFillWidthMultiplier: CGFloat! // 1 - gapWidthMult

    
    
    
    
    let playableRect: CGRect!
    
    let effectsLayer = SKNode()
    let textLayer = SKNode()
    
    var startButton: Button!
    var optionsButton: Button!
    var scoresButton: Button!
    var aboutButton: Button!
    
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
        
        effectsLayer.zPosition = 50
        textLayer.zPosition = 100
                
        addChild(effectsLayer)
        addChild(textLayer)
        
        setUpUI()
        
        let spawnAction = SKAction.sequence([
            SKAction.run(spawnWalls),
            SKAction.wait(forDuration: 1.7/1.8)])
        let mainAction = SKAction.repeatForever(spawnAction)
        
        run(mainAction, withKey: "wallLoop")
        
    }
    
    override func touchesBegan(_ touches: Set<NSObject>, with event: UIEvent) {
        let touch = touches.first as! UITouch
        
        if startButton.contains(touch.location(in: self)) {
            startButton.buttonTouched()
        }
        if optionsButton.contains(touch.location(in: self)) {
            optionsButton.buttonTouched()
        }
        if scoresButton.contains(touch.location(in: self)) {
            scoresButton.buttonTouched()
        }
        if aboutButton.contains(touch.location(in: self)) {
            aboutButton.buttonTouched()
        }
        
    }
    
    override func touchesMoved(_ touches: Set<NSObject>, with event: UIEvent) {
        let touch = touches.first as! UITouch
        
        // Checks if the button was pressed and the finger slid off of the button
        if startButton.buttonPressed && !startButton.contains(touch.location(in: self)) {
            startButton.buttonCancelled()
        }
        if optionsButton.buttonPressed && !optionsButton.contains(touch.location(in: self)) {
            optionsButton.buttonCancelled()
        }
        if scoresButton.buttonPressed && !scoresButton.contains(touch.location(in: self)) {
            scoresButton.buttonCancelled()
        }
        if aboutButton.buttonPressed && !aboutButton.contains(touch.location(in: self)) {
            aboutButton.buttonCancelled()
        }
        
    }
    
    override func touchesEnded(_ touches: Set<NSObject>, with event: UIEvent) {
        let touch = touches.first as! UITouch
        
        // Button clicked
        if startButton.buttonPressed && startButton.contains(touch.location(in: self)) {
            newGame()
        }
        if optionsButton.buttonPressed && optionsButton.contains(touch.location(in: self)) {
            optionsMenu()
        }
        if scoresButton.buttonPressed && scoresButton.contains(touch.location(in: self)) {
            highscoreScene()
        }
        if aboutButton.buttonPressed && aboutButton.contains(touch.location(in: self)) {
            aboutScene()
        }
        
    }
    
    func setUpUI() {
        
        let fingerRunLabel = SKLabelNode(fontNamed: "Edit Undo Line BRK")
        fingerRunLabel.fontSize = 150
        fingerRunLabel.text = "FINGER RUN"
        fingerRunLabel.position = CGPoint(x: size.width/2, y: size.height * 0.83)
        fingerRunLabel.fontColor = SKColor.white
        textLayer.addChild(fingerRunLabel)
        
        
        startButton = Button(
            size: CGSize(
                width: playableRect.width * 0.75,
                height: playableRect.height * 0.1),
            text: "START",
            name: "startButton",
            fontSize: 100)
        startButton.position = CGPoint(x: size.width/2, y: size.height * 0.65)
        textLayer.addChild(startButton)
        
        optionsButton = Button(
            size: CGSize(
                width: playableRect.width * 0.75,
                height: playableRect.height * 0.1),
            text: "OPTIONS",
            name: "optionsButton",
            fontSize: 100)
        optionsButton.position = CGPoint(x: size.width/2, y: size.height * 0.5)
        textLayer.addChild(optionsButton)
        
        scoresButton = Button(
            size: CGSize(
                width: playableRect.width * 0.75,
                height: playableRect.height * 0.1),
            text: "HIGH SCORE",
            name: "scoresButton",
            fontSize: 100)
        scoresButton.position = CGPoint(x: size.width/2, y: size.height * 0.35)
        textLayer.addChild(scoresButton)
        
        aboutButton = Button(
            size: CGSize(
                width: playableRect.width * 0.75,
                height: playableRect.height * 0.1),
            text: "HELP",
            name: "aboutButton",
            fontSize: 100)
        aboutButton.position = CGPoint(x: size.width/2, y: size.height * 0.2)
        textLayer.addChild(aboutButton)
    }
    
    func newGame() {
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = scaleMode
        
        let reveal = SKTransition.doorsOpenHorizontal(withDuration: 0.60)
        
        view?.presentScene(gameScene, transition: reveal)
    }
    
    func spawnWalls() {
        
        rectFillWidthMultiplier = 1.0 - gapWidthMultiplier
        
        // Creates left and right rects to be stored in the fullWallNode, which is set in motion and stored in the wall layer.
        let fullWallNode = SKSpriteNode()
        fullWallNode.name = "fullWallNode"
        
        let wall1 = SKShapeNode(rect: CGRect(
            x: 0,
            y: 0,
            width: playableRect.minX + CGFloat.random(min: 0, max: rectFillWidthMultiplier * playableRect.width),
            height: 100))
        wall1.fillColor = SKColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.2)
        wall1.strokeColor = SKColor.clearColor()
        wall1.name = "wall1"
        
        let wall2 = SKShapeNode(rect: CGRect(
            x: wall1.frame.width + (gapWidthMultiplier * playableRect.width),
            y: 0,
            width: size.width - (wall1.frame.width + (gapWidthMultiplier * playableRect.width)),
            height: 100))
        wall2.fillColor = SKColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.2)
        wall2.strokeColor = SKColor.clearColor()
        wall2.name = "wall2"

        
        fullWallNode.addChild(wall1)
        fullWallNode.addChild(wall2)
        fullWallNode.position = CGPoint(x: 0, y: size.height)
        
        fullWallNode.userData = NSMutableDictionary(object: false, forKey: "hasScored" as NSCopying)
        
        fullWallNode.run(SKAction.sequence([
            SKAction.moveTo(y: -128, duration: 1.7),
            SKAction.removeFromParent()]))
        
        effectsLayer.addChild(fullWallNode)
        
    }
    
    func optionsMenu() {
        let opScene = OptionsScene(size: size)
        opScene.scaleMode = scaleMode
        
        let reveal = SKTransition.doorsOpenHorizontal(withDuration: 0.60)
        
        view?.presentScene(opScene, transition: reveal)
    }
    
    func highscoreScene() {
        let hsScene = HighscoreScene(size: size)
        hsScene.scaleMode = scaleMode
        
        let reveal = SKTransition.doorsOpenHorizontal(withDuration: 0.60)
        
        view?.presentScene(hsScene, transition: reveal)
    }
    
    func aboutScene() {
        let abScene = AboutScene(size: size)
        abScene.scaleMode = scaleMode
        
        let reveal = SKTransition.doorsOpenHorizontal(withDuration: 0.60)
        
        view?.presentScene(abScene, transition: reveal)
    }

    
    
    
    
    
    
    
    
    
}
