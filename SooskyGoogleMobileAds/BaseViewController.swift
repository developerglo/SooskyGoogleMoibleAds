//
//  BaseViewController.swift
//  ChromeCast
//
//  Created by NhonGa on 8/30/21.
//

import UIKit
import GoogleMobileAds
import Foundation

func createAndLoadBanner(_ bannerView : GADBannerView,_ controller : UIViewController,_ heightConstraintBannerView : NSLayoutConstraint) -> GADBannerView{
    let storage = UserDefaults.standard
    if storage.string(forKey: defaultsKeys.APP_REMOVE_ADS) != nil
    {
        hideBanner(bannerView, heightConstraintBannerView)
    }
    else
    {
        if Constants.BANNER_ID == ""
        {
            heightConstraintBannerView.constant = 0
        }
        else
        {
            if !Reachability.isConnectedToNetwork() {
                heightConstraintBannerView.constant = 0
            }else{
                bannerView.adUnitID = Constants.BANNER_ID
                bannerView.rootViewController = controller
                bannerView.isAutoloadEnabled = true
                let request = GADRequest()
                bannerView.load(request)
            }
        }
    }
    return bannerView
}

func hideBanner(_ bannerView : GADBannerView, _ heightConstraintBannerView : NSLayoutConstraint)
{
    heightConstraintBannerView.constant = 0
    bannerView.layoutIfNeeded()
    bannerView.isHidden = true
}

func showBanner(_ bannerView : GADBannerView, _ heightConstraintBannerView : NSLayoutConstraint)
{
    heightConstraintBannerView.constant = 50
    bannerView.layoutIfNeeded()
    bannerView.isHidden = false
}


class BaseViewController: UIViewController {
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    let defaults = UserDefaults.standard
    let fileManager = FileManager.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
