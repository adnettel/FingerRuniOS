//
//  GameScene.swift
//  FingerRun
//
//  Created by Adam Nettel on 7/10/15.
//  Copyright (c) 2015 AdamDev. All rights reserved.
//

import SpriteKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let FingerLayer = SKNode()
    let hudLayerNode = SKNode()
    let wallLayerNode = SKNode()
    let powerUpLayerNode = SKNode()
    let shieldOpacityCoverLayer = SKSpriteNode()
    
    var gameHasStarted: Bool = false
    let startLabel = SKLabelNode(fontNamed: "Edit Undo Line BRK")
    let startLabel2 = SKLabelNode(fontNamed: "Edit Undo Line BRK")

    let FingerEmitterNode = SKEmitterNode(fileNamed: "FingerParticles")
    let RedFingerEmitterNode = SKEmitterNode(fileNamed: "RedFingerParticles")
    let finger: SKShapeNode = SKShapeNode(circleOfRadius: 60)
    var lastTouch: CGPoint?
    
    let playableRect: CGRect!
    
    let hudHeight: CGFloat = 128
    let scoreLabel = SKLabelNode(fontNamed: "Edit Undo Line BRK")
    var healthBar: SKSpriteNode!
    var score = 0
    var health = 3
    
    var gapWidthMultiplier: CGFloat = 2/5
    var rectFillWidthMultiplier: CGFloat! // 1 - gapWidthMult
    
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval?
    
    var WallTime: TimeInterval = 1.4
    var spawnAction: SKAction!
    var mainSequenceAction: SKAction!
    
    var invincible = false              // If true spawns transparent walls
    var gapShouldSpread = false         // If true spreads gap
    var timeOfSpread: TimeInterval = 0
    
    struct PhysCats {
        static let None: UInt32 = 0
        static let Edge: UInt32 = 0b1
        static let Finger: UInt32 = 0b10
        static let Wall: UInt32 = 0b100
        static let powerUp: UInt32 = 0b1000
    }
    
    struct MyColors {
        static let clear = SKColor.clear
        
        static let white = SKColor.white
        static let whiteStroke = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        
        static let red = SKColor.red
        static let redStroke = SKColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0)
        
        static let orange = SKColor.orange
        static let orangeStroke = SKColor(red: 0.5, green: 0.25, blue: 0.0, alpha: 1.0)
        
        static let yellow = SKColor.yellow
        static let yellowStroke = SKColor(red: 0.5, green: 0.5, blue: 0.0, alpha: 1.0)
        
        static let green = SKColor.green
        static let darkerGreen = SKColor(red: 0.0, green: 0.7, blue: 0.0, alpha: 1.0)
        static let greenStroke = SKColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
        
        static let teal = SKColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
        static let tealStroke = SKColor(red: 0.0, green: 0.5, blue: 0.5, alpha: 1.0)
        
        static let blue = SKColor.blue
        static let blueStroke = SKColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
        
        static let purple = SKColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0)
        static let purpleStroke = SKColor(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0)
    }
    var currentColor = 0
    var currentStroke = 0
    let colorOrder: [SKColor] = [MyColors.red, MyColors.orange, MyColors.yellow, MyColors.green, MyColors.teal, MyColors.blue, MyColors.purple, MyColors.white, MyColors.clear]
    let strokeOrder: [SKColor] = [MyColors.redStroke, MyColors.orangeStroke, MyColors.yellowStroke, MyColors.greenStroke, MyColors.tealStroke, MyColors.blueStroke, MyColors.purpleStroke, MyColors.whiteStroke, MyColors.red, MyColors.orange, MyColors.yellow, MyColors.green, MyColors.teal, MyColors.blue, MyColors.purple, MyColors.white]
    let healthColorOrder: [SKColor] = [MyColors.red, MyColors.yellow, MyColors.green]
    
    
    override init(size: CGSize) {
        
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let playableMargin = (size.width-playableWidth)/2.0
        playableRect = CGRect(x: playableMargin, y: 0,
            width: playableWidth,
            height: size.height - hudHeight)
        
        rectFillWidthMultiplier = 1.0 - gapWidthMultiplier
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.black
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "hideiAdBanner"), object: nil)

        
        startLabel.fontSize = 120
        startLabel.text = "TOUCH AND HOLD"
        startLabel.position = CGPoint(x: size.width/2, y: size.height * 0.55)
        startLabel.fontColor = SKColor.white
        addChild(startLabel)
        
        startLabel2.fontSize = 120
        startLabel2.text = "TO BEGIN"
        startLabel2.position = CGPoint(x: size.width/2, y: size.height * 0.45)
        startLabel2.fontColor = SKColor.white
        addChild(startLabel2)
        
        startLabel.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeOut(withDuration: 2.0),
            SKAction.fadeIn(withDuration: 2.0)])))
        startLabel2.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeOut(withDuration: 2.0),
            SKAction.fadeIn(withDuration: 2.0)])))
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let collision: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        // Decreases health if finger hits wall. Ends game if health = 0
        if collision == PhysCats.Finger | PhysCats.Wall {
            
            
            if !invincible {
                changeHealthBar(-1)
            }
            if health == 0 && SOUNDS_ENABLED {
                run(
                    SKAction.sequence([
                        SKAction.playSoundFileNamed("deathSound.wav", waitForCompletion: false),
                        SKAction.run(endGame)]))
            } else if health == 0 && !SOUNDS_ENABLED {
                endGame()
            }
        
        // If finger hits a powerUp, determine which body is the power up, which power up it is, then takes action. Then removes powerUp.
        } else if collision == PhysCats.Finger | PhysCats.powerUp {
            
            if contact.bodyA.categoryBitMask == PhysCats.powerUp {
                
                switch contact.bodyA.node!.name! {
                case "heart":
                    powerUpMessage("HEALTH")
                    changeHealthBar(1)
                case "shield":
                    shieldHit()
                case "snowflake":
                    // Increases up to 1.7 again or by 0.3 seconds
                    if WallTime > 1.7 - 0.15 {
                        WallTime = 1.7
                    } else {
                        WallTime = WallTime + 0.15
                    }
                    powerUpMessage("SLOWER")
                case "spreadGap":
                    gapShouldSpread = true
                    powerUpMessage("<- GAP ->")
                default:
                    println("Collision power up name error")
                }
                
                contact.bodyA.node!.removeFromParent()
            } else {
                
                switch contact.bodyB.node!.name! {
                case "heart":
                    powerUpMessage("HEALTH")
                    changeHealthBar(1)
                case "shield":
                    shieldHit()
                case "snowflake":
                    // Increases up to 1.7 again or by 0.3 seconds
                    if WallTime > 1.7 - 0.15 {
                        WallTime = 1.7
                    } else {
                        WallTime = WallTime + 0.15
                    }
                    powerUpMessage("SLOWER")
                case "spreadGap":
                    gapShouldSpread = true
                    powerUpMessage("<- GAP ->")
                default:
                    println("Collision power up name error")
                }
                
                contact.bodyB.node!.removeFromParent()
            }
            
        }
        
    }
    
    override func touchesBegan(_ touches: Set<NSObject>, with event: UIEvent) {
        let touch = touches.first as! UITouch
        lastTouch = touch.location(in: self)
        
        if !gameHasStarted {
            startGame()
            gameHasStarted = true
        }
        
        // Keeps finger node in playable rect.
        if lastTouch!.y <= playableRect.maxY {
            finger.run(SKAction.move(to: lastTouch!, duration: 0.05))
        } else {
            finger.run(
                SKAction.move(to: CGPoint(
                    x: lastTouch!.x,
                    y: playableRect.maxY), duration: 0.05))
        }
        
    }
    
    override func touchesMoved(_ touches: Set<NSObject>, with event: UIEvent) {
        let touch = touches.first as! UITouch
        
        lastTouch = touch.location(in: self)
        
        // Keeps finger node in playable rect.
        if lastTouch!.y <= playableRect.maxY {
            finger.position = lastTouch!
        } else {
            finger.position = CGPoint(x: lastTouch!.x, y: playableRect.maxY)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<NSObject>, with event: UIEvent) {
        if SOUNDS_ENABLED {
            run(
                SKAction.sequence([
                    SKAction.playSoundFileNamed("deathSound.wav", waitForCompletion: false),
                    SKAction.run(endGame)]))
        } else {
            endGame()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        if(gapShouldSpread){
            timeOfSpread = currentTime
            gapWidthMultiplier = 3/5
            gapShouldSpread = false
        }
        
        checkGap()
        updateUI()
        
        // If there is no action "wallLoop" after x spawn times, then make a new wall action with a faster speed.
        if self.action(forKey: "wallLoop") == nil && gameHasStarted {
            spawnAction = SKAction.sequence([
                SKAction.run(spawnWalls),
                SKAction.wait(forDuration: WallTime/1.8)])
            mainSequenceAction = SKAction.sequence([
                SKAction.repeat(spawnAction, count: 20),
                SKAction.run(accelerate)])
            run(mainSequenceAction, withKey: "wallLoop")
        }
        
        
        
    }
    
    func startGame() {
        
        startLabel.run(SKAction.sequence([
            SKAction.scale(to: 0.0, duration: 0.25),
            SKAction.removeFromParent()]))
        startLabel2.run(SKAction.sequence([
            SKAction.scale(to: 0.0, duration: 0.25),
            SKAction.removeFromParent()]))
        
        wallLayerNode.zPosition = 50
        shieldOpacityCoverLayer.zPosition = 55
        powerUpLayerNode.zPosition = 60
        FingerLayer.zPosition = 75
        hudLayerNode.zPosition = 100
        setUpUI()
        setUpFinger()
        addChild(FingerLayer)
        addChild(wallLayerNode)
        addChild(hudLayerNode)
        addChild(powerUpLayerNode)
        addChild(shieldOpacityCoverLayer)
        
        shieldOpacityCoverLayer.size = self.size
        shieldOpacityCoverLayer.anchorPoint = CGPoint.zero
        shieldOpacityCoverLayer.position = CGPoint.zero
        
        physicsWorld.contactDelegate = self
        
        // Runs the first X number of walls until acceleration in update()
        spawnAction = SKAction.sequence([
            SKAction.run(spawnWalls),
            SKAction.wait(forDuration: WallTime/1.8)])
        mainSequenceAction = SKAction.sequence([
            SKAction.repeat(spawnAction, count: 20),
            SKAction.run(accelerate)])
        
        run(mainSequenceAction, withKey: "wallLoop")
        
        // Spawns a new powerup every 15 seconds
        run(SKAction.sequence([
            SKAction.wait(forDuration: 5.0),
            SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.wait(forDuration: 15.0),
                    SKAction.run(spawnPowerUp)]))]))
        
        let DebugPlayableRect = SKShapeNode(rect: playableRect)
        DebugPlayableRect.fillColor = SKColor.clear
        DebugPlayableRect.strokeColor = SKColor.red
        DebugPlayableRect.lineWidth = 10.0
        //addChild(DebugPlayableRect)
    }
    
    func setUpFinger() {
        
        finger.fillColor = SKColor.white
        finger.position = CGPoint(x: frame.width/2, y: frame.height/10)
        finger.glowWidth = 20
        
        finger.physicsBody = SKPhysicsBody(circleOfRadius: finger.frame.width/2)
        finger.physicsBody!.affectedByGravity = false
        finger.physicsBody!.categoryBitMask = PhysCats.Finger
        finger.physicsBody!.collisionBitMask = PhysCats.None
        finger.physicsBody!.contactTestBitMask = PhysCats.Wall | PhysCats.powerUp
        
        let circleOutline = SKShapeNode(circleOfRadius: 80)
        circleOutline.fillColor = SKColor.clear
        circleOutline.strokeColor = SKColor(red: 255, green: 255, blue: 255, alpha: 0.6)
        circleOutline.lineWidth = 5.0
        circleOutline.glowWidth = 5
        
        // Pulse
        let action = SKAction.scale(to: 1.2, duration: 0.9)
        action.timingMode = SKActionTimingMode.easeInEaseOut
        let action2 = SKAction.scale(to: 1.0, duration: 0.9)
        action2.timingMode = SKActionTimingMode.easeInEaseOut
        
        circleOutline.run(
            SKAction.repeatForever(
                SKAction.sequence([action, action2])),
            withKey: "standardPulse")
        // /////
        
        finger.addChild(circleOutline)
        FingerEmitterNode?.targetNode = self
        FingerEmitterNode?.name = "fingerEmitterNode"
        RedFingerEmitterNode?.targetNode = self
        RedFingerEmitterNode?.name = "redFingerEmitterNode"
        finger.addChild(FingerEmitterNode!)
        
        FingerLayer.addChild(finger)
        
        
    }
    
    func setUpUI() {
        
        let backgroundSize = CGSize(width: size.width, height: hudHeight)
        let backgroundColor = SKColor.black
        let hudBarBackground = SKSpriteNode(color: backgroundColor, size: backgroundSize)
        hudBarBackground.position = CGPoint(x:0, y: size.height - hudHeight)
        hudBarBackground.anchorPoint = CGPoint.zero
        hudLayerNode.addChild(hudBarBackground)
        
        scoreLabel.fontSize = 100
        scoreLabel.text = "SCORE: 0"
        scoreLabel.name = "scoreLabel"
        
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.position = CGPoint(
            x: size.width/2,
            y: (size.height - hudHeight/2) + 5)
        hudLayerNode.addChild(scoreLabel)
        
        healthBar = SKSpriteNode(color: healthColorOrder[health-1], size: CGSize(width: playableRect.width, height: hudHeight/8))
        healthBar.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        healthBar.position = CGPoint(x: size.width/2, y: size.height - hudHeight)
        healthBar.color = healthColorOrder[health-1]
        hudLayerNode.addChild(healthBar)
        
        
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
        wall1.fillColor = colorOrder[currentColor]
        wall1.strokeColor = strokeOrder[currentStroke]
        wall1.lineWidth = 20
        wall1.name = "wall1"
        wall1.physicsBody = SKPhysicsBody(
            rectangleOfSize: wall1.frame.size,
            center: CGPoint(
                x: wall1.frame.width/2,
                y: wall1.frame.height/2))
        wall1.physicsBody!.affectedByGravity = false
        wall1.physicsBody!.categoryBitMask = PhysCats.Wall
        wall1.physicsBody!.collisionBitMask = PhysCats.None
        
        let wall2 = SKShapeNode(rect: CGRect(
            x: wall1.frame.width + (gapWidthMultiplier * playableRect.width),
            y: 0,
            width: size.width - (wall1.frame.width + (gapWidthMultiplier * playableRect.width)),
            height: 100))
        wall2.fillColor = colorOrder[currentColor]
        wall2.strokeColor = strokeOrder[currentStroke]
        wall2.lineWidth = 20
        wall2.name = "wall2"
        wall2.physicsBody = SKPhysicsBody(
            rectangleOfSize: wall2.frame.size,
            center: CGPoint(
                x: wall1.frame.width + (gapWidthMultiplier * playableRect.width) + (wall2.frame.width/2),
                y: wall2.frame.height/2))
        wall2.physicsBody!.affectedByGravity = false
        wall2.physicsBody!.categoryBitMask = PhysCats.Wall
        wall2.physicsBody!.collisionBitMask = PhysCats.None
        
        fullWallNode.addChild(wall1)
        fullWallNode.addChild(wall2)
        fullWallNode.position = CGPoint(x: 0, y: size.height)
        
        fullWallNode.userData = NSMutableDictionary(object: false, forKey: "hasScored" as NSCopying)
        
        fullWallNode.run(SKAction.sequence([
            SKAction.moveTo(y: -128, duration: WallTime),
            SKAction.removeFromParent()]))
        
        wallLayerNode.addChild(fullWallNode)
        
    }
    
    func updateUI() {
        
        // Checks if finger is above walls and if it has not already added to the score.
        wallLayerNode.enumerateChildNodes(withName: "fullWallNode") { node, _ in
            if self.lastTouch?.y > node.position.y + node.frame.height && node.userData!.object(forKey: "hasScored") as! Bool == false {
                self.score += 1
                self.scoreLabel.text = "SCORE: \(self.score)"
                node.userData!.setObject(true, forKey: "hasScored" as NSCopying)
            }
        }
        
        
    }
    
    func accelerate() {
        if WallTime > 0.9 {
            WallTime = WallTime - 0.15
        } else if WallTime == 0.8 {
            WallTime = WallTime - 0.1
        }
        
        //  Cycles through fill colors and ends at clear.
        if currentColor < colorOrder.count-1 {
            currentColor += 1
        }
        // Cycles through stroke colors indefinitely. First cycle uses all colors but second only uses bright ones for contrast.
        if currentStroke < strokeOrder.count-1 {
            currentStroke += 1
        } else {
            currentStroke = 8
        }
    }
    
    func spawnPowerUp() {
        
        let powerUp = Int(CGFloat.random(min: 0, max: 4))
        let spriteNode: SKSpriteNode!
        let emitter: SKEmitterNode!
        
        switch powerUp {
        case 0:
            spriteNode = SKSpriteNode(imageNamed: "heart")
            spriteNode!.name = "heart"
            emitter = SKEmitterNode(fileNamed: "HeartParticles")
        case 1:
            spriteNode = SKSpriteNode(imageNamed: "shield")
            spriteNode!.name = "shield"
            emitter = SKEmitterNode(fileNamed: "ShieldParticles")
        case 2:
            spriteNode = SKSpriteNode(imageNamed: "snowflake")
            spriteNode!.name = "snowflake"
            emitter = SKEmitterNode(fileNamed: "FreezeParticles")
        case 3:
            spriteNode = SKSpriteNode(imageNamed: "spreadGap")
            spriteNode!.name = "spreadGap"
            emitter = SKEmitterNode(fileNamed: "spreadGapParticles")
        default:
            spriteNode = nil
            emitter = nil
            println("Generated a random power up that was not 1-4")
        }
        
        emitter.targetNode = self
        spriteNode.addChild(emitter)
        spriteNode.physicsBody = SKPhysicsBody(rectangleOf: spriteNode.size)
        spriteNode.physicsBody!.categoryBitMask = PhysCats.powerUp
        spriteNode.physicsBody!.collisionBitMask = PhysCats.None
        
        spriteNode.position = CGPoint(
            x: CGFloat.random(
                min: playableRect.minX + spriteNode.size.width/2,
                max: playableRect.maxX - (spriteNode.size.width/2)),
            y: self.size.height)
        
        powerUpLayerNode.addChild(spriteNode)
        
        let pulse = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 1.0),
                SKAction.scale(to: 1.0, duration: 1.0)]))
        pulse.timingMode = SKActionTimingMode.easeInEaseOut
        
        // Power up pulses as it moves to the bottom of the screen where it is then removed.
        spriteNode?.run(
            SKAction.sequence([
                SKAction.group([
                    pulse,
                    SKAction.moveTo(y: -spriteNode.size.height, duration: 5.0)]),
                SKAction.removeFromParent()]))
        
    }
    
    func shieldHit() {
        invincible = true
        
        powerUpMessage("INVINCIBLE")
        
        let maskColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        shieldOpacityCoverLayer.run(
            SKAction.sequence([
                SKAction.colorize(with: maskColor, colorBlendFactor: 1.0, duration: 1.0),
                SKAction.wait(forDuration: 6.0),
                SKAction.colorize(with: SKColor.clear, colorBlendFactor: 1.0, duration: 3.0),
                SKAction.wait(forDuration: 1.0),
                SKAction.run(endInvincibility)]))
    }
    
    func endInvincibility() {
        invincible = false
    }
    
    func checkGap() {
        if lastUpdateTime - timeOfSpread > 10 {
            gapWidthMultiplier = 2/5
        }
    }
    
    func powerUpMessage(_ message: String) {
        
        if message == "HEALTH" && SOUNDS_ENABLED {
            run(SKAction.playSoundFileNamed("healthIncrease.wav", waitForCompletion: false))
        } else if SOUNDS_ENABLED {
            run(SKAction.playSoundFileNamed("powerUpSound.wav", waitForCompletion: false))
        }
        
        if message == "INVINCIBLE"{
            let label = SKLabelNode(fontNamed: "Edit Undo Line BRK")
            label.fontSize = 180
            label.text = message
            label.position = CGPoint(x: size.width/2, y: size.height/2)
            label.setScale(0.0)
            hudLayerNode.addChild(label)
            // Scale to 1, pulse 8 times, scale to 0. Total time = 10 seconds.
            let pulse1 = SKAction.scale(to: 0.8, duration: 0.5)
            let pulse2 = SKAction.scale(to: 1.0, duration: 0.5)
            pulse1.timingMode = SKActionTimingMode.easeInEaseOut
            pulse2.timingMode = SKActionTimingMode.easeInEaseOut
            label.run(SKAction.sequence([
                SKAction.scale(to: 1.0, duration: 1.0),
                SKAction.repeat(SKAction.sequence([
                    pulse1,
                    pulse2]), count: 8),
                SKAction.scale(to: 0.0, duration: 1.0),
                SKAction.removeFromParent()]))
        } else {
            
            let label = SKLabelNode(fontNamed: "Edit Undo Line BRK")
            label.fontSize = 180
            label.text = message
            label.position = CGPoint(x: size.width/2, y: size.height/2 - 200)
            label.fontColor = SKColor.white
            label.alpha = 0.0
            hudLayerNode.addChild(label)
            
            label.run(SKAction.group([
                SKAction.move(by: CGVector(dx: 0, dy: 400), duration: 2.0),
                SKAction.sequence([
                    SKAction.fadeIn(withDuration: 1.0),
                    SKAction.fadeOut(withDuration: 1.0)])]))
            
            
        }
    }
    
    func changeHealthBar(_ change: Int) {
        
        if health == 1 && change > 0 {
            finger.childNode(withName: "redFingerEmitterNode")?.removeFromParent()
            finger.addChild(FingerEmitterNode!)
        }
        
        if change > 0 && health < 3 {
            self.health = self.health + change
            
            // Adjusts bar width based on rect/5. Keeps health-1 within array bounds. Pusles at lowest health. Removes pulse when increasing.
            healthBar.size.width = healthBar.size.width + (CGFloat(change)*(2*(playableRect.width/5)))
            
        } else if change < 0 && health > 0 {
            self.health = self.health + change
            
            // Adjusts bar width based on rect/5. Keeps health-1 within array bounds. Pusles at lowest health. Removes pulse when increasing.
            healthBar.size.width = healthBar.size.width + (CGFloat(change)*(2*(playableRect.width/5)))
            
        }
        
        if health != 0 && SOUNDS_ENABLED {
            run(SKAction.playSoundFileNamed("wallCollision.wav", waitForCompletion: false))

        }
        
        if health > 0 {
            healthBar.color = healthColorOrder[health-1]
        }
        if health == 1 {
            healthBar.run(
                SKAction.repeatForever(
                    SKAction.sequence([
                        SKAction.scale(to: 1.4, duration: 0.1),
                        SKAction.scale(to: 1.0, duration: 0.1)])), withKey: "healthPulse")
            
            finger.childNode(withName: "fingerEmitterNode")?.removeFromParent()
            finger.addChild(RedFingerEmitterNode!)
        }
        if change > 0 {
            healthBar.removeAction(forKey: "healthPulse")
        }
        
        
        
    }
    
    func endGame() {

        let gameOverScene = GameOverScene(size: size, score: score)
        gameOverScene.scaleMode = scaleMode
        
        let reveal = SKTransition.doorsCloseHorizontal(withDuration: 0.60)
        
        view?.presentScene(gameOverScene, transition: reveal)
    }
    
    
    
    
    
    
    
    
    
}
