//
//  SplashController.swift
//  Ruteame
//
//  Created by Roberto Avalos on 27/04/16.
//  Copyright © 2016 Roberto Avalos. All rights reserved.
//

import Foundation
import UIKit

class SlpashController: UIViewController {
    
    @IBOutlet weak var splashImage: UIImageView!
    var countet:Int!
    var timer:NSTimer!
    var ban: Bool = true
    var slpashImage: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.hidden = true
        
        countet = 0;
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        
        if screenSize.height ==  480 {
            slpashImage = "iphone_4"
            self.splashImage.image = UIImage(named: slpashImage + ".png")
        }else if screenSize.height == 568 {
            slpashImage = "iphone_5"
            self.splashImage.image = UIImage(named: slpashImage + ".png")
        }else if screenSize.height == 667{
            slpashImage = "iphone_6"
            self.splashImage.image = UIImage(named: slpashImage + ".png")
            
        }else{
            slpashImage = "iphone_plus"
            self.splashImage.image = UIImage(named: slpashImage + ".png")
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.35, target: self, selector: #selector(SlpashController.someSelector), userInfo: nil, repeats: true)
        
    }
    
    func someSelector() {
        // Something after a delay
        
        if countet < 5{
            if (ban){
                self.splashImage.image = UIImage(named: slpashImage + ".png")
                ban = false
            }else{
                self.splashImage.image = UIImage(named: slpashImage + "_lights.png")
                ban = true
            }

        }else{
            let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("NavigationViewToMAin")
            self .presentViewController(viewController!, animated: true, completion: nil)
            timer .invalidate()
        
        }
       
        countet = countet + 1
        
    }

}