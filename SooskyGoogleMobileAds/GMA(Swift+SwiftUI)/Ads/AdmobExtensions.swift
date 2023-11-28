//
//  AdmobExtensions.swift
//  SooskyGoogleMobileAds
//
//  Created by Posu on 24/11/2023.
//

import Foundation
import UIKit

var countTimerShowAds : Int = 0
var timerShowAds : Timer? = nil

extension Notification.Name
{
    static let SHOW_ADS = Notification.Name("SHOW_ADS")
}

extension UIViewController{
    @objc func turnOffAds(){
        AdmobInterstitialAd.sharedInstance.currentVC = nil
        AdmobRewardedAd.sharedInstance.currentVC = nil
        AdmobInterstitialAd.sharedInstance.currentVC = nil
    }
    
    @objc func haveReward(){
        
    }
    
    @objc func dontHaveReward(){
        
    }
    
    func closeAdsFull()
    {
        DispatchQueue.main.async {[weak self] in
            guard let `self` = self else {return}
            self.turnOffAds()
        }
    }
    
    func closeAdsReward(_ isHaveRewared : Bool) {
        DispatchQueue.main.async {[weak self] in
            guard let `self` = self else {return}
            if isHaveRewared
            {
                self.haveReward()
            }
            else
            {
                self.dontHaveReward()
            }
            
            self.turnOffAds()
        }
    }
    
    func countAdsToShowVC(_ startAds : Int, _ loopAds : Int, _ countFullAds : inout Int)
    {
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
            showPopupLoadingAds(.POS_FULL)
        }
        else
        {
            closeAdsFull()
        }
    }
    
    func showPopupLoadingAds(_ pos : ADS_POS, _ isShowAdsWithSub : Bool = false){
        if !Reachability.isConnectedToNetwork() {
            turnOffAds()
            return
        }
        
        if UserDefaults.standard.string(forKey: defaultsKeys.APP_REMOVE_ADS) != nil && !isShowAdsWithSub{
            turnOffAds()
            return
        }
        
        if pos == .POS_FULL{
            AdmobInterstitialAd.sharedInstance.loadAds(self)
        }else if pos == .POS_REWARD{
            AdmobRewardedAd.sharedInstance.loadAds(self)
        }else{
            AdmobRewardedInterstitialAd.sharedInstance.loadAds(self)
        }
        
        enableAndDisableNaviAndTabbar(isEnable: false)
        countTimerShowAds = 5
        
        var parentView : UIView
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let window = appDelegate.window
        {
            parentView = window
        }
        else if let supperview = self.view.superview
        {
            parentView = supperview
        }
        else
        {
            parentView = self.view
        }
        
        let containerView : UIView = UIView()
        containerView.frame = parentView.bounds
        containerView.backgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.3)
        
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect.init(x: ((containerView.frame.width - 150) / 2), y: ((containerView.frame.height / 2 - 150)), width: 150, height: 150)
        loadingView.center = containerView.center
        loadingView.backgroundColor = UIColor.init(red: 68/255, green: 68/255, blue: 68/255, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        
        let textDes = UILabel.init(frame: CGRect(x : 0, y : 0, width : 150, height: 50))
        textDes.textColor = UIColor.white
        textDes.font = UIFont(name:"SegoeUI", size: 15.0)
        textDes.textAlignment = .center
        textDes.numberOfLines = 0
        textDes.center = CGPoint.init(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2 + 45)
        textDes.text = "Loading Ads..."
        loadingView.addSubview(textDes)
        
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect.init(x: 0, y: 0, width: 40, height: 40)
        actInd.style =
            UIActivityIndicatorView.Style.whiteLarge
        actInd.center = CGPoint.init(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        loadingView.addSubview(actInd)
        containerView.addSubview(loadingView)
        
        parentView.addSubview(containerView)
        
        let array : [Any] = [textDes, containerView, pos]
        timerShowAds = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimerAds), userInfo: array, repeats: true)
        
        actInd.startAnimating()
    }
    
    fileprivate func removePopupLoadingAds(_ timer: Timer, _ array: [Any], _ isFinishTime : Bool = false) {
        timer.invalidate()
        
        enableAndDisableNaviAndTabbar(isEnable: true)
        
        let containerView = array[1] as! UIView
        containerView.removeFromSuperview()
        
        if isFinishTime{
            turnOffAds()
        }
        
    }
    
    fileprivate func showAdsIfReady(_ timer: Timer, _ array: [Any]) {
        let pos = array[2] as! ADS_POS
        if pos == .POS_FULL && AdmobInterstitialAd.sharedInstance.canShowAds(){
            AdmobInterstitialAd.sharedInstance.showAdsFull()
            removePopupLoadingAds(timer, array)
        }else if pos == .POS_REWARD && AdmobRewardedAd.sharedInstance.canShowAds(){
            AdmobRewardedAd.sharedInstance.showAdsReward()
            removePopupLoadingAds(timer, array)
        }else if pos == .POS_FULL_REWARD && AdmobRewardedInterstitialAd.sharedInstance.canShowAds(){
            AdmobRewardedInterstitialAd.sharedInstance.showAdsReward()
            removePopupLoadingAds(timer, array)
        }
    }
    
    @objc func updateTimerAds(timer: Timer)
    {
        let array : [Any] = timer.userInfo as! [Any]
        countTimerShowAds -= 1
        let txLabel = array[0] as! UILabel
        txLabel.text = "Loading Ads..."
        
        if countTimerShowAds <= 0{
            removePopupLoadingAds(timer, array, true)
        }else{
            showAdsIfReady(timer, array)
        }
    }
    
    func enableAndDisableNaviAndTabbar(isEnable : Bool)
    {
        if let tabBarController = self.tabBarController, let tabBarItems = tabBarController.tabBar.items
        {
            tabBarItems.forEach { (item) in
                item.isEnabled = isEnable
            }
        }
        
        if let navigationController = self.navigationController
        {
            if let leftBarButtonItems = navigationController.navigationItem.leftBarButtonItems
            {
                leftBarButtonItems.forEach { (item) in
                    item.isEnabled = isEnable
                }
            }
            
            if let rightBarButtonItems = navigationController.navigationItem.rightBarButtonItems
            {
                rightBarButtonItems.forEach { (item) in
                    item.isEnabled = isEnable
                }
            }
        }
    }
}
