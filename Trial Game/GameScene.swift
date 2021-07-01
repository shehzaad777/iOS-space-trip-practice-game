//
//  GameScene.swift
//  Trial Game
//
//  Created by Shehzaad Daureeawoo on 6/27/21.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var label : SKLabelNode?
    var ship: SKSpriteNode?
    var fuel: SKSpriteNode?
    var portal: SKSpriteNode?
    var mars: SKSpriteNode?
    var background: SKSpriteNode?
    var ground: SKShapeNode?
    var level: Double? = 1.0
    let width = Constants.width
    let height = Constants.height
    var wait: SKAction?
    var block: SKAction?
    var sequence: SKAction?
    var playerLost: Bool = false
    var nextLevel: Bool = false
    var time: Int = 3
    var countdown: SKLabelNode?
    var countdownDecrement: SKAction?
    
    override func didMove(to view: SKView) {
        view.isUserInteractionEnabled = false
        self.mars = SKSpriteNode(imageNamed: "mars")
        self.mars?.size = CGSize(width: 480, height: 480)
        self.mars?.position = CGPoint(x: scene!.frame.midX + 50, y: scene!.frame.midY)
        self.mars?.zPosition = 0
        self.mars?.physicsBody?.affectedByGravity = false
        self.addChild(self.mars!)
        self.ground = SKShapeNode(rectOf: CGSize(width: scene!.frame.maxX * 2, height: 1))
        self.ground?.position = CGPoint(x: 0, y: scene!.frame.minY + 30)
        self.ground?.alpha = 0
        self.ground?.zPosition = 1
        
        self.ground?.blendMode = SKBlendMode(rawValue: SKBlendMode.alpha.rawValue)!
        self.ground?.fillColor = SKColor(cgColor: CGColor(gray: 255, alpha: 1))
        self.ground?.physicsBody = SKPhysicsBody(rectangleOf: self.ground!.frame.size)
        self.ground?.physicsBody?.pinned = true
    
        
        self.ground?.physicsBody?.affectedByGravity = false
        self.ground?.physicsBody?.allowsRotation = false
        self.addChild(self.ground!)
        self.background = SKSpriteNode(imageNamed: "background")
        self.background?.position = CGPoint(x: scene!.frame.midX, y: scene!.frame.midY)
        self.background?.size = CGSize(width: width, height: height)
        self.background?.zPosition = -1
        self.addChild(self.background!)
        self.ship = SKSpriteNode(imageNamed: "ship-1")
        self.ship!.size = CGSize(width: 150, height: 150)
        self.ship!.position = CGPoint(x: scene!.frame.minX + 100, y: scene!.frame.minY + 35)
        self.ship?.zPosition = 1
        self.ship?.physicsBody = SKPhysicsBody(texture: ship!.texture!, size: ship!.size)
        self.ship?.physicsBody?.isDynamic = true
        self.ship?.physicsBody?.affectedByGravity = true
        self.ship!.physicsBody?.mass = 1
        self.ship?.physicsBody?.contactTestBitMask = 1
        self.ship?.physicsBody?.collisionBitMask = 1
        self.ship?.name = "ship"
        self.ship?.physicsBody?.allowsRotation = false
        self.addChild(self.ship!)
        self.fuel = SKSpriteNode(imageNamed: "fuel")
        self.fuel?.size = CGSize(width: 75, height: 75)
        self.fuel?.position = CGPoint(x: scene!.frame.maxX - 100, y: scene!.frame.minY + 75)
        self.fuel?.zPosition = 1
        self.fuel?.physicsBody = SKPhysicsBody(rectangleOf: self.fuel!.size)
        self.fuel?.physicsBody?.isDynamic = true
        self.fuel?.physicsBody?.affectedByGravity = true
        self.fuel?.physicsBody?.mass = 1
        self.fuel?.physicsBody?.contactTestBitMask = 1
        self.fuel?.physicsBody?.collisionBitMask = 1
        self.fuel?.name = "fuel"
        self.addChild(self.fuel!)
        self.label = SKLabelNode(text: "Space Trip: Stage \(Int(level!))")
        self.label?.fontColor = UIColor.red
        self.label?.fontName = "HelveticaNeue-Bold"
        self.label?.fontSize = 31
        self.label?.position = CGPoint(x: scene!.frame.midX, y: scene!.frame.maxY - 30)
        self.label?.zPosition = 1
        self.addChild(self.label!)
        self.countdown = SKLabelNode(text: "Game starts in \(time)...")
        self.countdown?.fontColor = UIColor.red
        self.countdown?.fontName = "HelveticaNeue-Bold"
        self.countdown?.fontSize = 31
        self.countdown?.position = CGPoint(x: scene!.frame.midX, y: scene!.frame.midY)
        self.countdown?.zPosition = 1
        self.addChild(self.countdown!)
        self.countdownDecrement = SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.run({self.beginGame()})])
        let cc = SKAction.repeatForever(self.countdownDecrement!)
        self.run(cc, withKey: "countdown")
        physicsWorld.contactDelegate = self
        let deci = 2.0 - (level!/100.0)
        let timeInt = pow(2, deci)
        self.wait = SKAction.wait(forDuration: timeInt)
        self.block = SKAction.run({
            self.spawnAsteroid()
        })
        self.sequence = SKAction.sequence([self.wait!, self.block!])
        
        
        
    }
    
    func beginGame() {
        if self.time == 0 {
            endCountdown()
        }
        else {
            self.time -= 1
            self.countdown?.text = "Game starts in \(time)..."
        }
    }
    
    func endCountdown() {
        countdown?.removeFromParent()
        self.removeAction(forKey: "countdown")
        view!.isUserInteractionEnabled = true
        let astSeq = SKAction.repeatForever(self.sequence!)
        self.run(astSeq, withKey: "asteroids")
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if ((contact.bodyA.node?.name == "ship" && contact.bodyB.node?.name == "fuel")) {
            contact.bodyB.node?.removeFromParent()
            spawnPortal()
        }
        else if (contact.bodyB.node?.name == "ship" && contact.bodyA.node?.name == "fuel") {
            contact.bodyA.node?.removeFromParent()
            spawnPortal()
        }
        else if ((contact.bodyA.node?.name == "ship" && contact.bodyB.node?.name == "asteroid") || (contact.bodyB.node?.name == "ship" && contact.bodyA.node?.name == "asteroid")) {
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            self.label?.text = "Game Over"
            stopAsteroids()
            endSequence()
           
        }
        else if ((contact.bodyA.node?.name == "ship" && contact.bodyB.node?.name == "portal") || (contact.bodyB.node?.name == "ship" && contact.bodyA.node?.name == "portal")) {
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            self.removeAllChildren()
            self.level! += 1
            self.label?.text = "Space Trip: Stage \(Int(level!))"
            self.nextLevel = true
            stopAsteroids()
     
            
        }
        else if (contact.bodyA.node?.name == "asteroid") {
            contact.bodyA.node?.removeFromParent()
        }
        else if (contact.bodyB.node?.name == "asteroid") {
            contact.bodyB.node?.removeFromParent()
        }
    }
    
    @objc func spawnAsteroid() {
        let asteroid = SKSpriteNode(imageNamed: "asteroid")
        asteroid.name = "asteroid"
        asteroid.size = CGSize(width: 75, height: 75)
        asteroid.position = CGPoint(x: self.ship!.frame.midX, y: self.ship!.frame.midY + 250)
        asteroid.zPosition = 1
        asteroid.physicsBody = SKPhysicsBody(circleOfRadius: asteroid.size.width)
        asteroid.physicsBody?.isDynamic = true
        asteroid.physicsBody?.mass = 0.3
        asteroid.physicsBody?.linearDamping = 10
        asteroid.physicsBody?.contactTestBitMask = 1
        asteroid.physicsBody?.collisionBitMask = 1
        addChild(asteroid)
    }
    
    @objc func spawnPortal() {
        self.portal = SKSpriteNode(imageNamed: "portal")
        self.portal!.name = "portal"
        self.portal!.size = CGSize(width: 100, height: 100)
        self.portal!.position = CGPoint(x: scene!.frame.minX + 40, y: scene!.frame.minY + 50)
        self.portal!.zPosition = 1
        self.portal!.physicsBody = SKPhysicsBody(rectangleOf: portal!.size)
        self.portal!.physicsBody?.isDynamic = true
        self.portal!.alpha = 0
        self.portal!.physicsBody?.contactTestBitMask = 1
        self.portal!.physicsBody?.collisionBitMask = 1
        self.addChild(self.portal!)
        self.portal!.run(SKAction.fadeIn(withDuration: 0.5))
    }
    
    func endSequence() {
        let astronaut = SKSpriteNode(imageNamed: "astronaut")
        astronaut.size = CGSize(width: 200, height: 200)
        astronaut.position = CGPoint(x: scene!.frame.minX + 100, y: scene!.frame.maxY + 20)
        astronaut.zPosition = 1
        astronaut.physicsBody = SKPhysicsBody(rectangleOf: astronaut.size)
        astronaut.physicsBody?.isDynamic = true
        astronaut.physicsBody?.mass = 0.1
        astronaut.physicsBody?.linearDamping = 30
        addChild(astronaut)
        astronaut.run(SKAction.fadeIn(withDuration: 5))
        let thanksLabel = SKLabelNode(text: "Thanks for Playing!")
        thanksLabel.fontSize = 40
        thanksLabel.fontName = "HelveticaNeue-Bold"
        thanksLabel.fontColor = UIColor.orange
        thanksLabel.position = CGPoint(x: scene!.frame.midX, y: scene!.frame.midY)
        thanksLabel.zPosition = 1
        addChild(thanksLabel)
        self.ground!.removeFromParent()
        self.mars?.run(SKAction.fadeOut(withDuration: 5))
        self.label?.run(SKAction.fadeOut(withDuration: 5))
        thanksLabel.run(SKAction.fadeOut(withDuration: 10)) {
            self.playerLost = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let FlyLeft = SKAction.group([SKAction.moveBy(x: -50, y: 0, duration: 1),
                                      SKAction.animate(with: [
                                      SKTexture(imageNamed: "ship-1"),
                                        SKTexture(imageNamed: "ship-2"),
                                        SKTexture(imageNamed: "ship-1")
                                      ],
                                                       timePerFrame: 1/3)
                                     ])
        
        for t in touches {
            let position = t.location(in: self)
            if position.x >= scene!.frame.midX {
                if self.ship!.xScale < 0 {
                    self.ship?.xScale *= -1
                }
            self.ship?.run(SKAction.group([SKAction.moveBy(x: 50, y: 0, duration: 1),
                                           SKAction.animate(with: [
                                           SKTexture(imageNamed: "ship-1"),
                                            SKTexture(imageNamed: "ship-2"),
                                            SKTexture(imageNamed: "ship-1")
                                           ], timePerFrame: 1/3)
            
            
            ]))
            }
            else {
                if self.ship!.xScale > 0 {
                    self.ship?.xScale *= -1
                }
                self.ship?.run(FlyLeft)
            }
           
        }
    }
    
    func stopAsteroids() {
        self.removeAction(forKey: "asteroids")
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if self.playerLost == true {
            let nw = GameScene(size: CGSize(width: width, height: height))
            nw.level = 1
            self.removeAllChildren()
            view?.presentScene(nw, transition: SKTransition.push(with: .right, duration: 0.5))
        }
        if self.nextLevel {
        let nextStage = GameScene(size: CGSize(width: width, height: height))
            nextStage.level = level
            self.removeAllChildren()
            view?.presentScene(nextStage, transition: SKTransition.fade(withDuration: 0.5))
        }
    }
}
