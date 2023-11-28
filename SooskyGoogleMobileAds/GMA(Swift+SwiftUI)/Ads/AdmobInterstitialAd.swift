//
//  AdmobInterstitialAd.swift
//  SooskyGoogleMobileAds
//
//  Created by Posu on 24/11/2023.
//

import Foundation
import GoogleMobileAds

var countIdInterstitialAds = 0
class AdmobInterstitialAd : NSObject, GADFullScreenContentDelegate{
    public static let sharedInstance = AdmobInterstitialAd()
    override init(){
        
    }
    
    private var mInterstitialAd : GADInterstitialAd? = nil
    public var currentVC : UIViewController? = nil
    
    public func loadAds(_ vc : UIViewController){
        if !Reachability.isConnectedToNetwork() {return}
        if UserDefaults.standard.string(forKey: defaultsKeys.APP_REMOVE_ADS) != nil {return}
        if mInterstitialAd != nil {return}
       
        self.currentVC = vc
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: Constants.FULL_ID[countIdInterstitialAds], request: request) {[weak self] ads, error in
            guard let `self` = self else {return}
            guard error == nil else {
                print("[DEBUG] load ads Full error : \(error?.localizedDescription)")
                return
            }
            self.mInterstitialAd = ads
            self.mInterstitialAd?.fullScreenContentDelegate = self
        }
        
        if countIdInterstitialAds >= Constants.FULL_ID.count - 1{
            countIdInterstitialAds = 0
        }else{
            countIdInterstitialAds += 1
        }
    }
    
    func showAdsFull()
    {
        guard let _currentVC = self.currentVC, let _mInterstitialAd = mInterstitialAd else{
            self.currentVC?.closeAdsFull()
            return
        }
        
        _mInterstitialAd.present(fromRootViewController: _currentVC)
        
    }
    
    func canShowAds() -> Bool{
        return mInterstitialAd != nil
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        mInterstitialAd = nil
        self.currentVC?.closeAdsFull()
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        mInterstitialAd = nil
    }
}
