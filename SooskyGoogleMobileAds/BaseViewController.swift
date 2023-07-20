//
//  BaseViewController.swift
//  ChromeCast
//
//  Created by NhonGa on 8/30/21.
//

import UIKit
import GoogleMobileAds
import Foundation

class BaseViewController: UIViewController {
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    var currentDeviceID = ""
    
    let defaults = UserDefaults.standard
    let fileManager = FileManager.default

    var isLoadVideoFail : Bool = false
    var isHaveRewarded : Bool = false
    
    func turnOffAdsFull(){
        
    }
    
    func haveReward(){
        
    }
    
    func dontHaveReward(){
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension BaseViewController : GADFullScreenContentDelegate
{
    func closeAdsFull()
    {
        NotificationCenter.default.removeObserver(self, name: .SHOW_ADS, object: nil)
        
        DispatchQueue.main.async {[weak self] in
            guard let `self` = self else {return}
            self.turnOffAdsFull()
        }
    }
    
    func countAdsToShowVC(_ startAds : Int, _ loopAds : Int, _ countFullAds : inout Int)
    {
        NotificationCenter.default.addObserver(self, selector: #selector(ShowAdsFull), name: .SHOW_ADS, object: nil)
        if fullAds != nil
        {
            fullAds.fullScreenContentDelegate = self
        }else{
            createAndLoadInterstitial()
        }
        
        countFullAds += 1
        var isShowAds = false
        if countFullAds < startAds
        {
            isShowAds = false
        }
        else if countFullAds == startAds
        {
            isShowAds = true
        }
        else
        {
            if (countFullAds - startAds) % loopAds == 0
            {
                isShowAds = true
            }
            else
            {
                isShowAds = false
            }
        }
        
        if isShowAds
        {
            showActivityIndicatoryCountDown(isRV: false, pos: .SHOW_ADS) { (str) in
                if str == "removeads"
                {
                    closeAdsFull()
                }
            }
        }
        else
        {
            closeAdsFull()
        }
    }
    
    func showFull()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(ShowAdsFull), name: .SHOW_ADS, object: nil)
        
        if(fullAds != nil)
        {
            fullAds.fullScreenContentDelegate = self
        }else{
            createAndLoadInterstitial()
        }
        
        showActivityIndicatoryCountDown(isRV: false, pos: .SHOW_ADS) { (str) in
            if str == "removeads"
            {
                closeAdsFull()
            }
        }
    }
    
    @objc func ShowAdsFull()
    {
        DispatchQueue.main.async{
            if !showAdsInterstitial(self)
            {
                self.closeAdsFull()
            }
        }
        
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        if let _ = ad as? GADInterstitialAd {
            createAndLoadInterstitial()
            closeAdsFull()
        }else if let _ = ad as? GADRewardedAd {
            createAndLoadRewardedAds()
            closeAdsReward()
        }else{
            createAndLoadRewardInterstitial()
            closeAdsReward10s()
        }
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        self.isLoadVideoFail = true
        if let _ = ad as? GADInterstitialAd {
            fullAds = nil
        }else if let _ = ad as? GADRewardedAd {
            rewardAds = nil
        }else{
            fullRewardAds = nil
        }
    }
}

extension BaseViewController
{
    func showPopupConfirmToShowRewardAds(_ title : String, _ subTitle : String){
        self.showConfirmDialog(title: title, subtitle: subTitle, actionTitle: "YES", cancelTitle: "NO") { no in
            
        } actionHandler: { yes in
            self.showLoadingRewardAds()
        }
    }
    
    func showLoadingRewardAds(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.ShowAdsReward), name: .SHOW_ADS, object: nil)
        
        self.showActivityIndicatoryCountDown(isRV: true, pos: .SHOW_ADS) { (str) in
            if str == "loadVideo"
            {
                if self.isLoadVideoFail {
                    self.closeAdsReward()
                }
            }
        }
    }
    
    func showAdsReward()
    {
        self.isHaveRewarded = false
        let storage = UserDefaults.standard
        if storage.string(forKey: defaultsKeys.APP_REMOVE_ADS) != nil
        {
            return
        }
        
        guard let rewardAds = rewardAds else{
            createAndLoadRewardedAds()
            return
        }
        
        rewardAds.fullScreenContentDelegate = self
        rewardAds.present(fromRootViewController: self) {
            print("[DEBUG] Reward Ads received with currency: \(rewardAds.adReward.type), amount \(rewardAds.adReward.amount).")
            self.isHaveRewarded = true
        }
    }
    
    
    fileprivate func closeAdsReward() {
        NotificationCenter.default.removeObserver(self, name: .SHOW_ADS, object: nil)
        
        self.isLoadVideoFail = false
        DispatchQueue.main.async {[weak self] in
            guard let `self` = self else {return}
            if self.isHaveRewarded
            {
                self.haveReward()
            }
            else
            {
                self.dontHaveReward()
            }
        }
    }

    @objc func ShowAdsReward()
    {
        showAdsReward()
    }
}

extension BaseViewController
{
    func showPopupConfirmToShowRewardAds10s(_ title : String, _ subTitle : String){
        self.showConfirmDialog(title: title, subtitle: subTitle, actionTitle: "YES", cancelTitle: "NO") { no in
            
        } actionHandler: { yes in
            self.showLoadingRewardAds10s()
        }
    }
    
    func showLoadingRewardAds10s() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.ShowAdsReward10s), name: .SHOW_ADS, object: nil)
        
        self.showActivityIndicatoryCountDown(isRV: true, pos: .SHOW_ADS) { (str) in
            if str == "loadVideo"
            {
                if self.isLoadVideoFail {
                    self.closeAdsReward10s()
                }
            }
        }
    }
    
    func showAdsReward10s()
    {
        self.isHaveRewarded = false
        let storage = UserDefaults.standard
        if storage.string(forKey: defaultsKeys.APP_REMOVE_ADS) != nil
        {
            return
        }
        
        guard let rewardAds10 = fullRewardAds else{
            createAndLoadRewardInterstitial()
            return
        }
        
        rewardAds10.fullScreenContentDelegate = self
        rewardAds10.present(fromRootViewController: self) {
            print("[DEBUG] Reward Ads 10s received with currency: \(rewardAds10.adReward.type), amount \(rewardAds10.adReward.amount).")
            self.isHaveRewarded = true
        }
    }
    
    
    fileprivate func closeAdsReward10s() {
        NotificationCenter.default.removeObserver(self, name: .SHOW_ADS, object: nil)

        self.isLoadVideoFail = false
        DispatchQueue.main.async {[weak self] in
            guard let `self` = self else {return}
            if self.isHaveRewarded
            {
                self.haveReward()
            }
            else
            {
                self.dontHaveReward()
            }
        }
    }
    
    @objc func ShowAdsReward10s()
    {
        showAdsReward10s()
    }
}
