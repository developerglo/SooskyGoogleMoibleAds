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
            rewardAds = nil
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
        createAndLoadRewardedAds()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.ShowAdsReward), name: .SHOW_ADS, object: nil)
        
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
        
        let array : [Any] = [textDes, containerView, Notification.Name.SHOW_ADS]
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimerReward), userInfo: array, repeats: true)
        
        actInd.startAnimating()
    }
    
    @objc func updateTimerReward(timer: Timer)
    {
        let array : [Any] = timer.userInfo as! [Any]
        countTimerShowAds -= 1
        let txLabel = array[0] as! UILabel
        txLabel.text = "Loading Ads..."
        
        if rewardAds != nil || countTimerShowAds <= 0
        {
            timer.invalidate()
            
            enableAndDisableNaviAndTabbar(isEnable: true)
            
            let containerView = array[1] as! UIView
            containerView.removeFromSuperview()
            let posAdsFull = array[2] as! Notification.Name
            NotificationCenter.default.post(name: posAdsFull, object: nil)
            
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
            closeAdsReward()
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
