//
//  GameOverScene.swift
//  FingerRun
//
//  Created by Adam Nettel on 7/17/15.
//  Copyright (c) 2015 AdamDev. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    let playableRect: CGRect!
    
    let fireworksLayer = SKNode()
    let textLayer = SKNode()
    
    let score: Int!
    var highscore: Int!
    var hasNewHighscore = false
    
    var restartButton: Button!
    var menuButton: Button!
    
    var FireworkEmitter: SKEmitterNode!
    var randTime: TimeInterval = 0.3

    
    init(size: CGSize, score: Int) {
        
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let playableMargin = (size.width-playableWidth)/2.0
        playableRect = CGRect(x: playableMargin, y: 0,
            width: playableWidth,
            height: size.height)
        
        self.score = score
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "showiAdBanner"), object: nil)
        
        fireworksLayer.zPosition = 50
        textLayer.zPosition = 100
        
        addChild(fireworksLayer)
        addChild(textLayer)
        
        checkHighScore()
        showLabels()
        showButtons()
        
    }
    
    override func touchesBegan(_ touches: Set<NSObject>, with event: UIEvent) {
        let touch = touches.first as! UITouch
        
        if restartButton.contains(touch.location(in: self)) {
            restartButton.buttonTouched()
        }
        if menuButton.contains(touch.location(in: self)) {
            menuButton.buttonTouched()
        }
        
    }
    
    override func touchesMoved(_ touches: Set<NSObject>, with event: UIEvent) {
        let touch = touches.first as! UITouch
        
        // Checks if the button was pressed and the finger slid off of the button
        if restartButton.buttonPressed && !restartButton.contains(touch.location(in: self)) {
            restartButton.buttonCancelled()
        }
        if menuButton.buttonPressed && !menuButton.contains(touch.location(in: self)) {
            menuButton.buttonCancelled()
        }
    }
    
    override func touchesEnded(_ touches: Set<NSObject>, with event: UIEvent) {
        let touch = touches.first as! UITouch
        
        // Button clicked
        if restartButton.buttonPressed && restartButton.contains(touch.location(in: self)) {
            newGame()
        }
        if menuButton.buttonPressed && menuButton.contains(touch.location(in: self)) {
            loadMainMenu()
        }
    }
    
    func showLabels() {
        let gameOverLabel = SKLabelNode(fontNamed: "Edit Undo Line BRK")
        gameOverLabel.fontSize = 150
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.position = CGPoint(x: size.width/2, y: size.height * 0.75)
        gameOverLabel.fontColor = SKColor.white
        textLayer.addChild(gameOverLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "Edit Undo Line BRK")
        scoreLabel.fontSize = 100
        scoreLabel.text = "SCORE: \(score)"
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height * 0.65)
        scoreLabel.fontColor = SKColor.white
        textLayer.addChild(scoreLabel)
        
        let highScoreLabel = SKLabelNode(fontNamed: "Edit Undo Line BRK")
        highScoreLabel.fontSize = 100
        highScoreLabel.text = "HIGH SCORE: \(highscore)"
        highScoreLabel.position = CGPoint(x: size.width/2, y: size.height * 0.55)
        highScoreLabel.fontColor = SKColor.white
        textLayer.addChild(highScoreLabel)
        
        if hasNewHighscore {
            let action1 = SKAction.scale(to: 1.3, duration: 0.25)
            let action2 = SKAction.scale(to: 1.0, duration: 0.25)
            action1.timingMode = SKActionTimingMode.easeInEaseOut
            action2.timingMode = SKActionTimingMode.easeInEaseOut
            
            highScoreLabel.run(SKAction.repeat(SKAction.sequence([action1, action2]), count: 16))
        }
    }
    
    func showButtons() {
        
        restartButton = Button(
            size: CGSize(
                width: playableRect.width * 0.75,
                height: playableRect.height * 0.1),
            text: "RESTART",
            name: "restartButton",
            fontSize: 100)
        restartButton.position = CGPoint(x: size.width/2, y: size.height * 0.45)
        addChild(restartButton)
        
        menuButton = Button(
            size: CGSize(
                width: playableRect.width * 0.75,
                height: playableRect.height * 0.1),
            text: "MAIN MENU",
            name: "menuButton",
            fontSize: 100)
        menuButton.position = CGPoint(x: size.width/2, y: size.height * 0.3)
        addChild(menuButton)
        
    }
    
    func checkHighScore() {
        
        if let defaults = UserDefaults.standard.object(forKey: "highscore") as? Int {
            highscore = defaults
            
            if score > highscore {
                highscore = score
                UserDefaults.standard.set(highscore, forKey: "highscore")
                newHighscore()
            }
            
        } else {
            UserDefaults.standard.set(score, forKey: "highscore")
            highscore = score
            newHighscore()
        }
        
    }
    
    func newHighscore() {
        hasNewHighscore = true
        
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run(spawnFirework),
            SKAction.wait(forDuration: randTime)])))
        
    }
    
    func spawnFirework() {
        
        //fireworksLayer.removeAllChildren()
        
        randTime = TimeInterval(Double(CGFloat.random(min: 0.3, max: 2.0)))
        
        // Random x and y values for the position
        let randX = CGFloat.random(min: playableRect.minX, max: playableRect.maxX)
        let randY = CGFloat.random(min: playableRect.minY, max: playableRect.maxY)
        let randFW = CGFloat.random(min: 0, max: 100)
        
        // Rainbow has 20% chance, others have 40% chance
        if randFW < 40 {
            FireworkEmitter = SKEmitterNode(fileNamed: "Firework")
        } else if randFW >= 40 && randFW < 80 {
            FireworkEmitter = SKEmitterNode(fileNamed: "Firework2")
        } else {
            FireworkEmitter = SKEmitterNode(fileNamed: "Firework3")
        }
        
        FireworkEmitter.position = CGPoint(x: randX, y: randY)
        fireworksLayer.addChild(FireworkEmitter)
        
        //FireworkEmitter.resetSimulation()
        
    }
    
    func newGame() {
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = scaleMode
        
        let reveal = SKTransition.doorsOpenHorizontal(withDuration: 0.60)
        
        view?.presentScene(gameScene, transition: reveal)
    }
    
    func loadMainMenu() {
        let menuScene = MainMenuScene(size: size)
        menuScene.scaleMode = scaleMode
        
        let reveal = SKTransition.doorsCloseHorizontal(withDuration: 0.60)
        
        view?.presentScene(menuScene, transition: reveal)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
