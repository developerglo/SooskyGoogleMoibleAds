//
//  AdmobAppOpenAd.swift
//  SooskyGoogleMobileAds
//
//  Created by Posu on 27/11/2023.
//

import Foundation
import GoogleMobileAds

var countTierOpenAds = 0
var canShowOpenAds : Bool = false

class AdmobAppOpenAd : NSObject, GADFullScreenContentDelegate{
    public static let sharedInstance = AdmobAppOpenAd()
    override init(){
        
    }
    
    private var appOpenAd : GADAppOpenAd? = nil
    private var loadTime = Date()
    public var displayAOA : Int = 0
    
    func requestAppOpenAd() {
        if !Reachability.isConnectedToNetwork(){return}
        if self.displayAOA == 0{
            if self.appOpenAd != nil {return}
            if !canShowOpenAds{return}
            canShowOpenAds = false
        }else{
            self.appOpenAd = nil
        }
        
        let request = GADRequest()
        GADAppOpenAd.load(withAdUnitID: Constants.OPEN_ID[countTierOpenAds],
                          request: request,
                          orientation: UIInterfaceOrientation.portrait,
                          completionHandler: { (appOpenAdIn, error) in
            guard error == nil else {
                print("[DEBUG] load Open Ads error : \(error?.localizedDescription)")
                self.appOpenAd = nil
                return
            }
            self.appOpenAd = appOpenAdIn
            self.appOpenAd?.fullScreenContentDelegate = self
            
            if self.displayAOA == 0{
                if let gOpenAd = self.appOpenAd, let delegate = UIApplication.shared.delegate as? AppDelegate,
                   let rwc = delegate.window?.rootViewController {
                    gOpenAd.present(fromRootViewController: rwc)
                }
            }else{
                self.loadTime = Date()
            }
        })
        
        if self.displayAOA == 0{
            if countTierOpenAds >= Constants.OPEN_ID.count - 1{
                countTierOpenAds = 0
            }else{
                countTierOpenAds += 1
            }
        }
    }
    
    func tryToPresentAd() {
        if displayAOA == 0{
            self.requestAppOpenAd()
        }else{
            if let gOpenAd = self.appOpenAd, wasLoadTimeLessThanNHoursAgo(thresholdN: 4), let delegate = UIApplication.shared.delegate as? AppDelegate,
               let rwc = delegate.window?.rootViewController {
                gOpenAd.present(fromRootViewController: rwc)
            } else {
                self.requestAppOpenAd()
            }
        }
    }

    func wasLoadTimeLessThanNHoursAgo(thresholdN: Int) -> Bool {
        let now = Date()
        let timeIntervalBetweenNowAndLoadTime = now.timeIntervalSince(self.loadTime)
        let secondsPerHour = 3600.0
        let intervalInHours = timeIntervalBetweenNowAndLoadTime / secondsPerHour
        return intervalInHours < Double(thresholdN)
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        if displayAOA == 0{
            self.appOpenAd = nil
        }
        
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        self.appOpenAd = nil
    }
}
