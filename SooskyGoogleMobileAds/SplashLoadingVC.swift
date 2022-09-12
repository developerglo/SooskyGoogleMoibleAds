//
//  SplashLoadingVC.swift
//  RokuTV
//
//  Created by admin on 4/1/21.
//  Copyright © 2021 Nabeel. All rights reserved.
//

import UIKit

class SplashLoadingVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createAndLoadInterstitial()
        createAndLoadRewardInterstitial()
        createAndLoadRewardedAds()
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
            self.configVC()
        }
    }
    
    func configVC(){
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.configVC()
    }
}
