//
//  AdmobRewardAd.swift
//  SooskyGoogleMobileAds
//
//  Created by Posu on 24/11/2023.
//

import Foundation
import GoogleMobileAds

class AdmobRewardedAd : NSObject, GADFullScreenContentDelegate{
    public static let sharedInstance = AdmobRewardedAd()
    override init(){
        
    }
    
    private var mRewardAd : GADRewardedAd? = nil
    private var countTierRewardAds = 0
    public var currentVC : UIViewController? = nil
    var isHaveRewarded : Bool = false
    
    public func loadAds(_ vc : UIViewController){
        if !Reachability.isConnectedToNetwork() {return}
        if mRewardAd != nil {return}
        self.currentVC = vc
        
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: Constants.VIDEO_ID[countTierRewardAds], request: request) {[weak self] ads, error in
            guard let `self` = self else{return}
            guard error == nil else {
                print("[DEBUG] load ads Reward error : \(error?.localizedDescription)")
                return
            }
            self.mRewardAd = ads
            self.mRewardAd?.fullScreenContentDelegate = self
        }
        
        if countTierRewardAds >= Constants.VIDEO_ID.count - 1{
            countTierRewardAds = 0
        }else{
            countTierRewardAds += 1
        }
    }
    
    func showAdsReward()
    {
        self.isHaveRewarded = false
        
        guard let _currentVC = self.currentVC, let _mRewardAd = mRewardAd else{
            self.currentVC?.closeAdsReward(self.isHaveRewarded)
            return
        }
        
        _mRewardAd.present(fromRootViewController: _currentVC) {
            print("[DEBUG] Reward Ads received with currency: \(_mRewardAd.adReward.type), amount \(_mRewardAd.adReward.amount).")
            self.isHaveRewarded = true
        }
    }
    
    func canShowAds() -> Bool{
        return mRewardAd != nil
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        mRewardAd = nil
        self.currentVC?.closeAdsReward(self.isHaveRewarded)
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        mRewardAd = nil
    }
}
