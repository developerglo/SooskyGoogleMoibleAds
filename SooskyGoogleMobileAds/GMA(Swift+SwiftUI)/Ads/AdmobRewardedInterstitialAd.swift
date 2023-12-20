//
//  AdmobInterstitialRewardedAd.swift
//  SooskyGoogleMobileAds
//
//  Created by Posu on 24/11/2023.
//

import Foundation
import GoogleMobileAds

class AdmobRewardedInterstitialAd : NSObject, GADFullScreenContentDelegate{
    public static let sharedInstance = AdmobRewardedInterstitialAd()
    override init(){
        
    }
    
    private var mRewardedInterstitial : GADRewardedInterstitialAd? = nil
    public var currentVC : UIViewController? = nil
    var isHaveRewarded : Bool = false
    
    public func loadAds(_ vc : UIViewController){
        if !Reachability.isConnectedToNetwork() {return}
        if mRewardedInterstitial != nil {return}
        self.currentVC = vc
        
        let request = GADRequest()
        GADRewardedInterstitialAd.load(withAdUnitID: Constants.VIDEO_FULL_ID, request: request) {[weak self] ads, error in
            guard let `self` = self else{return}
            guard error == nil else {
                print("[DEBUG] load ads Reward error : \(error?.localizedDescription)")
                return
            }
            self.mRewardedInterstitial = ads
            self.mRewardedInterstitial?.fullScreenContentDelegate = self
        }
    }
    
    func showAdsReward()
    {
        self.isHaveRewarded = false
        
        guard let _currentVC = self.currentVC, let _mRewardAd = mRewardedInterstitial else{
            self.currentVC?.closeAdsReward(self.isHaveRewarded)
            return
        }
        
        _mRewardAd.present(fromRootViewController: _currentVC) {
            print("[DEBUG] Reward Ads received with currency: \(_mRewardAd.adReward.type), amount \(_mRewardAd.adReward.amount).")
            self.isHaveRewarded = true
        }
    }
    
    func canShowAds() -> Bool{
        return mRewardedInterstitial != nil
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        mRewardedInterstitial = nil
        self.currentVC?.closeAdsReward(self.isHaveRewarded)
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        mRewardedInterstitial = nil
    }
}
