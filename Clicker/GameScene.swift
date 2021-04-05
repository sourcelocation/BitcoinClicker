//
//  GameScene.swift
//  Clicker
//
//  Created by Матвей Анисович on 3/28/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var bigCoin: SKSpriteNode!
    var topBar: SKShapeNode!
    
    var moneyLabel:SKLabelNode!
    var moneyIcon: SKSpriteNode!
    var coinLabel:SKLabelNode!
    var coinIcon: SKSpriteNode!
    
    var delayCoinCost: SmartNumber = SmartNumber(numberOfSections: 1, currentSection: .one)
    var maxRandomCoins: Double = 1
    var automaticDelay: Double = 999999
    var coinSize: Double = 50.0
    
    var money = SmartNumber(numberOfSections: 0.0, currentSection: .one)
    var coins = SmartNumber(numberOfSections: 0.0, currentSection: .one)
    var coinCost = SmartNumber(numberOfSections: 0.002, currentSection: .one)
    
    
    var coinBoost:SmartNumber {
        return SmartNumber(numberOfSections: 20**coinLevel, currentSection: .one)
    }
    var coinLevel = 0
    
    var coinNames = ["Nano", "Chainlink", "Neo", "Dash", "Litecoin", "Monero", "Bitcoin Cash", "Etherium", "Maker", "Bitcoin", "Dogecoin", "Nyancoin", "Cookie", "Obama", "Rickroll"]
    var upgradePrices: [SmartNumber] = [
        SmartNumber(numberOfSections: 300, currentSection: .thousand),
        SmartNumber(numberOfSections: 2, currentSection: .billion),
        SmartNumber(numberOfSections: 1.5, currentSection: .trillion),
        SmartNumber(numberOfSections: 5, currentSection: .quadrillion),
        SmartNumber(numberOfSections: 3, currentSection: .quintillion),
        SmartNumber(numberOfSections: 5, currentSection: .sextillion),
        SmartNumber(numberOfSections: 2.5, currentSection: .septillion),
        SmartNumber(numberOfSections: 5, currentSection: .octillion),
        SmartNumber(numberOfSections: 3, currentSection: .nonillion),
        SmartNumber(numberOfSections: 500, currentSection: .decillion),
        SmartNumber(numberOfSections: 5, currentSection: .undecillion),
        SmartNumber(numberOfSections: 2.5, currentSection: .duodecillion),
        SmartNumber(numberOfSections: 7.5, currentSection: .tredecillion),
//        SmartNumber(numberOfSections: 50, currentSection: .quattuordecillion),
        SmartNumber(numberOfSections: 10, currentSection: .quattuordecillion),
    ]
    var shopButtons:[ShopButton] = []
    
    override func sceneDidLoad() {
        // Load save data
        if UserDefaults.standard.string(forKey: "money-currentSection") != nil {
            money.currentSection = NumberName(rawValue: UserDefaults.standard.string(forKey: "money-currentSection")!)!
            coins.currentSection = NumberName(rawValue: UserDefaults.standard.string(forKey: "coins-currentSection")!)!
            
            delayCoinCost.currentSection = NumberName(rawValue: UserDefaults.standard.string(forKey: "delayCoinCost-currentSection") ?? "one") ?? .one
            
            coinCost.currentSection = NumberName(rawValue: UserDefaults.standard.string(forKey: "coinCost-currentSection") ?? "one") ?? .one
        }
        money.numberOfSections = UserDefaults.standard.double(forKey: "money-numberOfSections")
        coins.numberOfSections = UserDefaults.standard.double(forKey: "coins-numberOfSections")
        
        coinSize = UserDefaults.standard.double(forKey: "coinSize") == 0 ? 50 : UserDefaults.standard.double(forKey: "coinSize")
        
        coinCost.numberOfSections = UserDefaults.standard.double(forKey: "coinCost-numberOfSections") == 0 ? 0.002 : UserDefaults.standard.double(forKey: "coinCost-numberOfSections")
        
        delayCoinCost.numberOfSections = UserDefaults.standard.double(forKey: "delayCoinCost-numberOfSections") == 0 ? 1 : UserDefaults.standard.double(forKey: "delayCoinCost-numberOfSections")
        
        
        maxRandomCoins = UserDefaults.standard.double(forKey: "maxRandomCoins") == 0 ? 1 : UserDefaults.standard.double(forKey: "maxRandomCoins")
        automaticDelay = UserDefaults.standard.double(forKey: "automaticDelay") == 0 ? 99999 : UserDefaults.standard.double(forKey: "automaticDelay")
        coinLevel = UserDefaults.standard.integer(forKey: "coinLevel")
        
        
        bigCoin = SKSpriteNode(imageNamed: coinNames[coinLevel])
        bigCoin.name = "coin"
        bigCoin.position = CGPoint(x: 0, y: 100)
        bigCoin.zPosition = -1
        bigCoin.size = CGSize(width: 400, height: 400)
        addChild(bigCoin)
        
        topBar = SKShapeNode(rect: CGRect(x: -size.width / 2, y: size.height / 2 - 100 - (UIDevice.current.hasNotch ? 50 : 0), width: size.width, height: 170), cornerRadius: 50)
        topBar.fillColor = .gray
        addChild(topBar)
        
        
        moneyLabel = SKLabelNode(text: "0.00")
        moneyIcon = SKSpriteNode(imageNamed: "money")
        moneyIcon.size = CGSize(width: 50, height: 50)
        moneyLabel.fontName = "ArialRoundedMTBold"
        let positions1 = positionsOfMoneyLabelAndIcon()
        moneyLabel.position = positions1.0
        addChild(moneyLabel)
        moneyIcon.position = positions1.1
        addChild(moneyIcon)
        
        coinLabel = SKLabelNode(text: "0")
        coinIcon = SKSpriteNode(imageNamed: coinNames[coinLevel] + "-small")
        coinIcon.size = CGSize(width: 35, height: 35)
        coinLabel.fontName = "ArialRoundedMTBold"
        coinLabel.fontSize = 30
        let positions2 = positionsOfCoinLabelAndIcon()
        coinLabel.position = positions2.0
        addChild(coinLabel)
        coinIcon.position = positions2.1
        addChild(coinIcon)
        
        let scrollView = SKScrollView(color: .gray, size: CGSize(width: 950, height: 150))
        scrollView.zPosition = 10
        scrollView.position = CGPoint(x: -size.width / 2 + scrollView.size.width / 2, y: -size.height / 2 + 75)
        scrollView.isUserInteractionEnabled = true
        addChild(scrollView)
        
        createFloor()
        createWalls()
        
        
        let shopButton1 = ShopButton(rect: CGRect(x: -scrollView.size.width / 2 + 30, y: -62.5, width: 125, height: 125), cornerRadius: 25)
        shopButton1.positionOfButton = CGPoint(x: -scrollView.size.width / 2 + 30, y: -62.5)
        let price1 = SmartNumber(numberOfSections: UserDefaults.standard.double(forKey: "value-numberOfSections") == 0 ? 10 : UserDefaults.standard.double(forKey: "value-numberOfSections"), currentSection: NumberName(rawValue: (UserDefaults.standard.string(forKey: "value-currentSection") == nil ? "one" : UserDefaults.standard.string(forKey: "value-currentSection"))!)!)
        shopButton1.setup(title: "Value", price: price1)
        scrollView.addChild(shopButton1)
        
        let shopButton2 = ShopButton(rect: CGRect(x: -scrollView.size.width / 2 + 180, y: -62.5, width: 125, height: 125), cornerRadius: 25)
        shopButton2.positionOfButton = CGPoint(x: -scrollView.size.width / 2 + 180, y: -62.5)
        let price2 = SmartNumber(numberOfSections: UserDefaults.standard.double(forKey: "delay-numberOfSections") == 0 ? 20 : UserDefaults.standard.double(forKey: "delay-numberOfSections"), currentSection: NumberName(rawValue: (UserDefaults.standard.string(forKey: "delay-currentSection") == nil ? "one" : UserDefaults.standard.string(forKey: "delay-currentSection"))!)!)
        shopButton2.setup(title: "Delay", price:price2)
        scrollView.addChild(shopButton2)
        
        let shopButton3 = ShopButton(rect: CGRect(x: -scrollView.size.width / 2 + 330, y: -62.5, width: 125, height: 125), cornerRadius: 25)
        shopButton3.positionOfButton = CGPoint(x: -scrollView.size.width / 2 + 330, y: -62.5)
        let price3 = SmartNumber(numberOfSections: UserDefaults.standard.double(forKey: "auto-numberOfSections") == 0 ? 30 : UserDefaults.standard.double(forKey: "auto-numberOfSections"), currentSection: NumberName(rawValue: (UserDefaults.standard.string(forKey: "auto-currentSection") == nil ? "one" : UserDefaults.standard.string(forKey: "auto-currentSection"))!)!)
        shopButton3.setup(title: "Auto", price: price3)
        scrollView.addChild(shopButton3)
        
        let shopButton4 = ShopButton(rect: CGRect(x: -scrollView.size.width / 2 + 480, y: -62.5, width: 125, height: 125), cornerRadius: 25)
        shopButton4.positionOfButton = CGPoint(x: -scrollView.size.width / 2 + 480, y: -62.5)
        let price4 = SmartNumber(numberOfSections: UserDefaults.standard.double(forKey: "count-numberOfSections") == 0 ? 50 : UserDefaults.standard.double(forKey: "count-numberOfSections"), currentSection: NumberName(rawValue: (UserDefaults.standard.string(forKey: "count-currentSection") == nil ? "one" : UserDefaults.standard.string(forKey: "count-currentSection"))!)!)
        shopButton4.setup(title: "Count", price: price4)
        scrollView.addChild(shopButton4)
        
        let shopButton5 = ShopButton(rect: CGRect(x: -scrollView.size.width / 2 + 630, y: -62.5, width: 125, height: 125), cornerRadius: 25)
        shopButton5.positionOfButton = CGPoint(x: -scrollView.size.width / 2 + 630, y: -62.5)
        let price5 = SmartNumber(numberOfSections: UserDefaults.standard.double(forKey: "size-numberOfSections") == 0 ? 1 : UserDefaults.standard.double(forKey: "size-numberOfSections"), currentSection: NumberName(rawValue: (UserDefaults.standard.string(forKey: "size-currentSection") == nil ? "million" : UserDefaults.standard.string(forKey: "size-currentSection"))!)!)
        shopButton5.setup(title: "Size", price: price5)
        scrollView.addChild(shopButton5)
        
        let upgradeButton = ShopButton(rect: CGRect(x: -scrollView.size.width / 2 + 780, y: -62.5, width: 125, height: 125), cornerRadius: 25)
        upgradeButton.positionOfButton = CGPoint(x: -scrollView.size.width / 2 + 780, y: -62.5)
        var priceUpgradeButton = upgradePrices[coinLevel]
        let _ = priceUpgradeButton.updateNumber()
        upgradeButton.setup(title: "Upgrade", price: priceUpgradeButton)
        scrollView.addChild(upgradeButton)
        
        shopButtons += [shopButton1,shopButton2,shopButton3,shopButton4,shopButton5,upgradeButton]
        
        run(.repeatForever(.sequence([.wait(forDuration: 0.5),.run {
            UserDefaults.standard.setValue(self.money.currentSection.rawValue, forKey: "money-currentSection")
            UserDefaults.standard.setValue(self.coins.currentSection.rawValue, forKey: "coins-currentSection")
            UserDefaults.standard.setValue(self.money.numberOfSections, forKey: "money-numberOfSections")
            UserDefaults.standard.setValue(self.coins.numberOfSections, forKey: "coins-numberOfSections")
            
            UserDefaults.standard.setValue(self.delayCoinCost.numberOfSections, forKey: "delayCoinCost-numberOfSections")
            UserDefaults.standard.setValue(self.delayCoinCost.currentSection.rawValue, forKey: "delayCoinCost-currentSection")
            
            UserDefaults.standard.setValue(self.coinCost.numberOfSections, forKey: "coinCost-numberOfSections")
            UserDefaults.standard.setValue(self.coinCost.currentSection.rawValue, forKey: "coinCost-currentSection")
            
            UserDefaults.standard.setValue(self.maxRandomCoins, forKey: "maxRandomCoins")
            UserDefaults.standard.setValue(self.automaticDelay, forKey: "automaticDelay")
            UserDefaults.standard.setValue(self.coinLevel, forKey: "coinLevel")
            UserDefaults.standard.setValue(self.coinSize, forKey: "coinSize")
        }])))
        self.run(.repeatForever(.sequence([.wait(forDuration: 0.016),.run {
            var toAdd = self.coinCost * self.coins
            toAdd *= self.delayCoinCost
            toAdd *= self.coinBoost
            self.money += toAdd
            for button in self.shopButtons {
                if !(self.money >= button.price) {
                    button.alpha = 0.5
                } else {
                    button.alpha = 1.0
                }
            }
        }])))
        automaticSpawn()
    }
        
    func automaticSpawn() {
        self.run(.sequence([.wait(forDuration: self.automaticDelay),.run {
            self.spawnCoin()
            self.animateBigCoin(small: true)
        }]),completion: {
            self.automaticSpawn()
        })
    }
    
    func touchDown(atPoint pos : CGPoint) {
//        guard let sprite = atPoint(pos) as? SKSpriteNode else { return }
        if bigCoin.frame.contains(pos) {
            animateBigCoin(small: false)
            self.generateFeedback(style: .light)
            for _ in 1...(Int(Double.random(in: 1...maxRandomCoins).rounded(.toNearestOrAwayFromZero))) {
                spawnCoin()
            }
        }
    }
    func touchMoved(toPoint pos : CGPoint) {
        var generateFeedback = false
        var node1: SKNode?
        for node in children {
            guard let sprite1 = node as? SKSpriteNode else { continue }
            if node1 == nil {
                node1 = node
            }
            if sprite1.position.distance(to: pos) < 100, sprite1.name == "smallCoin", !bigCoin.frame.contains(sprite1.position), sprite1.physicsBody != nil {
                sprite1.physicsBody = nil
                sprite1.run(.fadeAlpha(to: 0.5, duration: 0.5))
                sprite1.run(.sequence([.move(to: CGPoint(x: coinIcon.position.x, y: coinIcon.position.y + 50) , duration: 0.5),.run {
                    self.coins += SmartNumber(numberOfSections: 1, currentSection: .one)
                },.run {
                    self.coinIcon.run(.sequence([.scale(to: 1.2, duration: 0.05),.scale(to: 1, duration: 0.05)]))
                },.removeFromParent()]))
                
                generateFeedback = true
            }
        }
        if generateFeedback {
            self.generateFeedback(style: .light)
            run(.playSoundFileNamed("coin2.wav", waitForCompletion: true))
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    func animateBigCoin(small:Bool = false) {
        bigCoin.run(.sequence([.scale(to: small ? 0.97 : 0.9, duration: 0.05),.scale(to: 1, duration: 0.05)]))
    }
    func spawnCoin() {
        let coin = SKSpriteNode(imageNamed: coinNames[coinLevel] + "-small")
        coin.position = CGPoint(x: 0, y: 100)
        coin.size = CGSize(width: coinSize, height: coinSize)
        coin.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(coinSize / 2))
        coin.physicsBody?.velocity = CGVector(dx: .random(in: -350...350), dy: .random(in:0...700))
        coin.physicsBody?.contactTestBitMask = 1
        coin.physicsBody?.fieldBitMask = 1
        coin.physicsBody?.categoryBitMask = 1
        coin.physicsBody?.collisionBitMask = 1
        coin.name = "smallCoin"
        addChild(coin)
        coin.run(.repeatForever(.sequence([.wait(forDuration: 1),.run {
            if coin.position.y < -self.size.height / 2 { coin.removeFromParent() }
        }])))
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        moneyLabel.text = money.string(short: false)
        coinLabel.text = String(Int(coins.double()))
        
        let positions = positionsOfMoneyLabelAndIcon()
        moneyLabel.position = positions.0
        moneyIcon.position = positions.1
        
        let positions2 = positionsOfCoinLabelAndIcon()
        coinLabel.position = positions2.0
        coinIcon.position = positions2.1
    }
    
    
    func positionsOfMoneyLabelAndIcon() -> (CGPoint, CGPoint) {
        let labelWidth = moneyLabel.frame.width
        let imageWidth = moneyIcon.size.width
        let sum = labelWidth + imageWidth
        let spacing: CGFloat = 40
        var iconPosition = CGPoint(x: imageWidth, y: size.height / 2 - (UIDevice.current.hasNotch ? 80 : 32))
        iconPosition.x -= sum / 2
        iconPosition.x -= spacing / 2

        let labelPosition = CGPoint(x: iconPosition.x + spacing + labelWidth / 2, y: iconPosition.y - moneyLabel.frame.height / 2)
        
        return (labelPosition,iconPosition)
    }
    func positionsOfCoinLabelAndIcon() -> (CGPoint, CGPoint) {
        let labelWidth = coinLabel.frame.width
        let imageWidth = coinIcon.size.width
        let sum = labelWidth + imageWidth
        let spacing: CGFloat = 30
        var iconPosition = CGPoint(x: imageWidth, y: size.height / 2 - (UIDevice.current.hasNotch ? 80 : 32) - 45)
        iconPosition.x -= sum / 2
        iconPosition.x -= spacing / 2

        let labelPosition = CGPoint(x: iconPosition.x + spacing + labelWidth / 2, y: iconPosition.y - coinLabel.frame.height / 2 + 2)
        
        return (labelPosition,iconPosition)
    }
    
    
    func createFloor() {
        let floor = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: 200))
        floor.fillColor = .darkGray
        floor.strokeColor = .clear
        
        floor.position.y = -size.height / 2
        floor.position.x = -size.width / 2
        
        floor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 200), center: CGPoint(x: size.width / 2, y: 100))
        
        floor.physicsBody!.contactTestBitMask = 1
        floor.physicsBody?.fieldBitMask = 1
        floor.physicsBody?.categoryBitMask = 1
        floor.physicsBody?.collisionBitMask = 2
        floor.physicsBody?.pinned = true
        floor.physicsBody?.affectedByGravity = false
        floor.physicsBody?.allowsRotation = false
        
        addChild(floor)
    }
    func createWalls() {
        let wall = SKShapeNode(rect: CGRect(x: -125, y: 0, width: 200, height: 500))
        wall.lineWidth = 0
        wall.position.x = -self.size.width / 2 + 125
        wall.position.y = -self.size.height / 2 + 150
        wall.zRotation = 0.5
        wall.fillColor = .darkGray
        
        wall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 200, height: 500), center: CGPoint(x: -25, y: wall.frame.height / 2))
        wall.physicsBody!.contactTestBitMask = 1
        wall.physicsBody?.fieldBitMask = 1
        wall.physicsBody?.categoryBitMask = 1
        wall.physicsBody?.collisionBitMask = 3
        wall.physicsBody?.pinned = true
        wall.physicsBody?.affectedByGravity = false
        wall.physicsBody?.allowsRotation = false
        
        addChild(wall)
        
        let wall2 = wall.copy() as! SKShapeNode
        wall2.position.x = self.size.width / 2 - 100
        wall2.position.y = -self.size.height / 2 + 100
        wall2.zRotation = -0.5
        addChild(wall2)
    }
    func generateFeedback(style:UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
}

class ShopButton: SKShapeNode {
    var initPrice = SmartNumber(numberOfSections: 10.0, currentSection: .one)
    var positionOfButton: CGPoint!
    var price = SmartNumber(numberOfSections: 10.0, currentSection: .one) {
        didSet {
            update()
        }
    }
    var label: SKLabelNode!
    var priceLabel: SKLabelNode!
    
    func update() {
        priceLabel.text = price.string(short: true)
    }
    func setup(title: String, price: SmartNumber) {
        fillColor = .gray
        strokeColor = .orange
        lineWidth = 5
        zPosition = 999
        
        label = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        label.fontSize = 25
        label.text = title
        label.position.x = frame.width / 2 - 3
        label.position.y = frame.height - 42
        label.position += positionOfButton
        label.name = title
        addChild(label)
        
        let image = SKSpriteNode(imageNamed: title + "Image")
        image.size = CGSize(width: 50, height: 50)
        if ["Auto","Count","Upgrade"].contains(title) {
            image.size = CGSize(width: 40, height: 40)
        }
        if title == "Upgrade" {
            label.fontSize = 20
            label.position.y += 1
        }
        image.position = CGPoint(x: frame.width / 2, y: frame.height / 2 - 8)
        image.position += positionOfButton
        image.name = title
        addChild(image)
        
        priceLabel = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        priceLabel.fontSize = 20
        priceLabel.text = self.price.string(short: true)
        priceLabel.position.x = frame.width / 2 - 3
        priceLabel.position.y = 13
        priceLabel.position += positionOfButton
        priceLabel.name = title
        addChild(priceLabel)
        
        name = title
        self.price = price
        self.initPrice = price
    }
    func reset() {
        if name == "Value" {
            self.price = SmartNumber(numberOfSections: 10, currentSection: .one)
        } else if name == "Delay" {
            self.price = SmartNumber(numberOfSections: 20, currentSection: .one)
        } else if name == "Auto" {
            self.price = SmartNumber(numberOfSections: 30, currentSection: .one)
        } else if name == "Count" {
            self.price = SmartNumber(numberOfSections: 50, currentSection: .one)
        } else if name == "Size" {
            self.price = SmartNumber(numberOfSections: 1, currentSection: .million)
        }
    }
    func savePrice() {
        UserDefaults.standard.setValue(self.price.currentSection.rawValue, forKey: "\(name!.lowercased())-currentSection")
        UserDefaults.standard.setValue(self.price.numberOfSections, forKey: "\(name!.lowercased())-numberOfSections")
    }
}

class SKScrollView: SKSpriteNode {
    var previousX: CGFloat = 0
    var dx:CGFloat = 0.0
    var started = false
    var gameScene: GameScene!
    
    private var isScrolling = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        previousX = touch.location(in: parent!).x
        
        if !started {
            start()
            started = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: parent!)
        let difference = previousX - location.x
        
        if fixPos() {
            // Move if allowed
            self.position.x -= difference
            if difference > 5 {
                isScrolling = true
            }
        }
        previousX = location.x
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: parent!)
        let difference = (previousX - location.x) * 1.2
        dx = difference
        
        touchUp(atPoint: touch.location(in: self))
        isScrolling = false
    }
    func start() {
        run(.repeatForever(.sequence([.wait(forDuration: 0.016),.run {
            self.position.x -= self.dx
            let success = self.fixPos()
            if success {
                self.dx /= 1.05
            }
        }])))
        self.gameScene = (parent as! GameScene)
    }
    func fixPos() -> Bool {
        let minX = -parent!.frame.width / 2 + size.width / 2 + (UIDevice.current.hasNotch ? 70 : 0)
        let maxX = parent!.frame.width / 2 - size.width / 2 - (UIDevice.current.hasNotch ? 70 : 0)
        if position.x > minX{
            position.x = minX
            return false
        } else if position.x < maxX {
            position.x = maxX
            return false
        }
        return true
    }
    func touchUp(atPoint pos : CGPoint) {
        var node = atPoint(pos)
        
        if !isScrolling {
            if node.name == "Value" {
                if node.parent?.name == "Value" { node = node.parent! }
                guard let node = node as? ShopButton else { return }
                if gameScene.money >= node.price {
                    gameScene.money -= node.price
                    node.price *= SmartNumber(numberOfSections: 3.9, currentSection: .one)
                    node.price.numberOfSections = node.price.numberOfSections.rounded(toPlaces: 1)
                    gameScene.coinCost *= SmartNumber(numberOfSections: 1.3, currentSection: .one)
                    if !(gameScene.money >= node.price) {
                        node.alpha = 0.5
                    } else {
                        node.alpha = 1.0
                    }
                    node.savePrice()
                    gameScene.generateFeedback(style: .medium)
                }
            } else if node.name == "Delay" {
                if node.parent?.name == "Delay" { node = node.parent! }
                guard let node = node as? ShopButton else { return }
                if gameScene.money >= node.price {
                    gameScene.money -= node.price
                    node.price *= SmartNumber(numberOfSections: 3.7, currentSection: .one)
                    node.price.numberOfSections = node.price.numberOfSections.rounded(toPlaces: 1)
                    gameScene.delayCoinCost *= SmartNumber(numberOfSections: 1.5, currentSection: .one)
                    if !(gameScene.money >= node.price) {
                        node.alpha = 0.5
                    } else {
                        node.alpha = 1.0
                    }
                    node.savePrice()
                    gameScene.generateFeedback(style: .medium)
                }
            } else if node.name == "Auto" {
                if node.parent?.name == "Auto" { node = node.parent! }
                guard let node = node as? ShopButton else { return }
                if gameScene.money >= node.price {
                    gameScene.money -= node.price
                    node.price *= SmartNumber(numberOfSections: 50, currentSection: .one)
                    node.price.numberOfSections = node.price.numberOfSections.rounded(toPlaces: 1)
                    if gameScene.automaticDelay > 9999 {
                        gameScene.automaticDelay = 3
                        gameScene.automaticSpawn()
                    } else {
                        gameScene.automaticDelay = (gameScene.automaticDelay / 1.3).rounded(toPlaces: 3)
                    }
                    if !(self.gameScene.money >= node.price) {
                        node.alpha = 0.5
                    } else {
                        node.alpha = 1.0
                    }
                    node.savePrice()
                    gameScene.generateFeedback(style: .medium)
                }
            } else if node.name == "Count" {
                if node.parent?.name == "Count" { node = node.parent! }
                guard let node = node as? ShopButton else { return }
                if gameScene.money >= node.price {
                    gameScene.money -= node.price
                    node.price *= SmartNumber(numberOfSections: 1, currentSection: .thousand)
                    node.price.numberOfSections.round()
                    gameScene.maxRandomCoins += 1
                    if !(gameScene.money >= node.price) {
                        node.alpha = 0.5
                    } else {
                        node.alpha = 1.0
                    }
                    node.savePrice()
                    gameScene.generateFeedback(style: .medium)
                }
            } else if node.name == "Size" {
                if node.parent?.name == "Size" { node = node.parent! }
                guard let node = node as? ShopButton else { return }
                if gameScene.money >= node.price {
                    gameScene.money -= node.price
                    node.price *= node.price
                    node.price.numberOfSections.round()
                    gameScene.coinSize /= 1.5
                    for node in gameScene.children {
                        if node.name == "smallCoin" {
                            let sprite = node as! SKSpriteNode
                            sprite.size = CGSize(width: gameScene.coinSize, height: gameScene.coinSize)
                            sprite.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(gameScene.coinSize / 2))
                        }
                    }
                    if !(gameScene.money >= node.price) {
                        node.alpha = 0.5
                    } else {
                        node.alpha = 1.0
                    }
                    node.savePrice()
                    gameScene.generateFeedback(style: .medium)
                }
            } else if node.name == "Upgrade" {
                if node.parent?.name == "Upgrade" { node = node.parent! }
                guard let node = node as? ShopButton else { return }
                if gameScene.money >= node.price {
                    gameScene.coinLevel += 1
                    
                    gameScene.money = SmartNumber(numberOfSections: 0, currentSection: .one)
                    gameScene.coinCost = SmartNumber(numberOfSections: 0.005, currentSection: .one)
                    gameScene.coins = SmartNumber(numberOfSections: 0, currentSection: .one)
                    gameScene.automaticDelay = 99999
                    gameScene.delayCoinCost = SmartNumber(numberOfSections: 1, currentSection: .one)
                    gameScene.maxRandomCoins = 1
                    gameScene.coinSize = 50
                    
                    for button in gameScene.shopButtons {
                        if button.name != "Upgrade" {
                            button.reset()
                            button.savePrice()
                            button.update()
                        }
                    }
                    
                    for node in gameScene.children {
                        if node.name == "smallCoin" {
                            let sprite = node as! SKSpriteNode
                            sprite.physicsBody = nil
                            sprite.run(.sequence([.fadeAlpha(to: 0, duration: 0.2),.removeFromParent()]))
                        }
                    }
                    
                    node.update()
                    
                    gameScene.bigCoin.texture = SKTexture(imageNamed: gameScene.coinNames[gameScene.coinLevel])
                    gameScene.coinIcon.texture = SKTexture(imageNamed: gameScene.coinNames[gameScene.coinLevel] + "-small")
                    
                    node.price = gameScene.upgradePrices[gameScene.coinLevel]
                    node.price.numberOfSections.round()
                    gameScene.maxRandomCoins += 1
                    if !(gameScene.money >= node.price) {
                        node.alpha = 0.5
                    } else {
                        node.alpha = 1.0
                    }
                    gameScene.generateFeedback(style: .medium)
                }
            }
        }
    }
}
