//
//  GameViewController.swift
//  FingerRun
//
//  Created by Adam Nettel on 7/10/15.
//  Copyright (c) 2015 AdamDev. All rights reserved.
//

import UIKit
import SpriteKit
import iAd

extension SKNode {
    class func unarchiveFromFile(_ file : String) -> SKNode? {
        if let path = Bundle.main.path(forResource: file, ofType: "sks") {
            var sceneData = Data(bytesNoCopy: path, count: .DataReadingMappedIfSafe, deallocator: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController, ADBannerViewDelegate {
    
    var UIiAd: ADBannerView?
    var toldToHide = false
    
    var SH = UIScreen.main.bounds.height
    var BV: CGFloat = 0
    
    func appdelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        println("Showing ad")
        UIiAd = self.appdelegate().UIiAd
        BV = UIiAd!.bounds.height
        
        UIiAd!.delegate = self
        UIiAd!.frame = CGRect(x: 0, y: SH - BV, width: 0, height: 0)
        if !UIiAd!.isBannerLoaded {
            UIiAd!.isHidden = true
        }
        self.view.addSubview(UIiAd!)
    }
    
    /*override func viewWillDisappear(animated: Bool) {
        UIiAd!.delegate = nil
        UIiAd = nil
        UIiAd!.removeFromSuperview()
    }*/
    
    func bannerViewDidLoadAd(_ banner: ADBannerView!) {
        println("ad loaded")
        if !toldToHide {
            UIiAd!.isHidden = false
        }
    }
    
    func bannerView(_ banner: ADBannerView!, didFailToReceiveAdWithError error: Error!) {
        println("failed to receive ad")
        UIiAd!.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.showiAdBanner), name: NSNotification.Name(rawValue: "showiAdBanner"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.hideiAdBanner), name: NSNotification.Name(rawValue: "hideiAdBanner"), object: nil)
        
        let scene = MainMenuScene(size: CGSize(width: 1536, height: 2048))
        
        let skView = self.view as! SKView
        //skView.showsFPS = true
        //skView.showsNodeCount = true
        
        skView.ignoresSiblingOrder = true
        
        scene.scaleMode = .aspectFill
        //skView.showsPhysics = true
        skView.presentScene(scene)
        
    }
    
    func showiAdBanner() {
        if UIiAd!.isBannerLoaded {
            UIiAd!.isHidden = false
        }
        toldToHide = false
    }
    
    func hideiAdBanner() {
        UIiAd!.isHidden = true
        toldToHide = true
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
