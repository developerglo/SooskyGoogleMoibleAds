//
//  FunctionCommon.swift
//  Music Player
//
//  Created by NhonGa on 16/08/2018.
//  Copyright © 2018 NhonGa. All rights reserved.
//

import Foundation
import GoogleMobileAds

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if hexString.hasPrefix("#")  {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format: "#%06x", rgb)
    }
}

var countTimerShowAds : Int = 0
var timer : Timer? = nil
var PositionAdsFull = ["Tutorial", "ListPlaying", "CustomTabbar"]

extension Notification.Name
{
    static let SHOW_ADS = Notification.Name("SHOW_ADS")
}

extension UIViewController {
    func showContent(string: String?, isNav : Bool) {
        guard let urlString = string, let url = URL(string: urlString) else { return }
        let webBrowserViewController = WebBrowserViewController()
//        webBrowserViewController.delegate = self
        
        webBrowserViewController.onOpenExternalAppHandler = { [weak self] _ in
            guard let `self` = self else { return }
            if isNav{
                self.navigationController?.popViewController(animated: true)
            }else{
                self.dismiss(animated: true, completion: nil)
            }
            
        }

//        webBrowserViewController.tintColor = AppConstants.shared.primaryColor
//        webBrowserViewController.barTintColor = AppConstants.shared.primaryBgColor
        webBrowserViewController.isToolbarHidden = true
        webBrowserViewController.isShowActionBarButton = true
        webBrowserViewController.toolbarItemSpace = 50
        webBrowserViewController.isShowURLInNavigationBarWhenLoading = true
        webBrowserViewController.isShowPageTitleInNavigationBar = true
        webBrowserViewController.loadURL(url)
        webBrowserViewController.castButton.isEnabled = false
        
        if isNav{
            self.navigationController?.pushViewController(webBrowserViewController, animated: true)
        }else{
            self.present(webBrowserViewController, animated: true, completion: nil)
        }
    }
    
    func getSafeHeight() -> CGFloat{
        let guide = self.view.safeAreaLayoutGuide
        let heightSafeArea = guide.layoutFrame.size.height
        return heightSafeArea
    }
    
    func getSafeTopAndBottom() -> (CGFloat, CGFloat){
        var topSafeArea: CGFloat = 0
        var bottomSafeArea: CGFloat = 0

        if #available(iOS 11.0, *) {
            topSafeArea = self.view.safeAreaInsets.top
            bottomSafeArea = self.view.safeAreaInsets.bottom
        } else {
            topSafeArea = self.topLayoutGuide.length
            bottomSafeArea = self.bottomLayoutGuide.length
        }
        
        return (topSafeArea, bottomSafeArea)
    }
    
    func getParentView() -> UIView{
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
        return parentView
    }
    
    enum HUDIndicatorView{
        case success
        case error
    }
    
    func showSubs(_ screenName : String) {
        if screenName == "SubscriptionB"{
            isOpenSubs = true
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tutvc = storyboard.instantiateViewController(withIdentifier: screenName)
        tutvc.modalPresentationStyle = .fullScreen
        self.present(tutvc, animated: true, completion: nil)
    }
    
    func hideActivityIndicatorys()
    {
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
        if let viewWithTag = parentView.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }else{
            print("xxx error hideActivityIndicatorys")
        }
    }
    
    func showActivityIndicatory()
    {
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
        containerView.tag = 100
        
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect.init(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = view.center
        loadingView.backgroundColor = UIColor.init(red: 68/255, green: 68/255, blue: 68/255, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect.init(x: 0, y: 0, width: 40, height: 40)
        actInd.style =
            UIActivityIndicatorView.Style.whiteLarge
        actInd.center = CGPoint.init(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        loadingView.addSubview(actInd)
        containerView.addSubview(loadingView)
        parentView.addSubview(containerView)
        actInd.startAnimating()
    }
    
    func showActivityIndicatoryTitle() -> (UILabel, UIProgressView)
    {
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
        containerView.tag = 100
        
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect.init(x: 0, y: 0, width: 150, height: 150)
        loadingView.center = view.center
        loadingView.backgroundColor = UIColor.init(red: 68/255, green: 68/255, blue: 68/255, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        
        let textDes = UILabel.init(frame: CGRect(x : 0, y : 0, width : 150, height: 50))
        textDes.textColor = UIColor.white
        textDes.font = UIFont(name:"SegoeUI", size: 15.0)
        textDes.textAlignment = .center
        textDes.numberOfLines = 0
        textDes.center = CGPoint.init(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2 + 45)
        loadingView.addSubview(textDes)
        
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect.init(x: 0, y: 0, width: 40, height: 40)
        actInd.style =
            UIActivityIndicatorView.Style.whiteLarge
        actInd.center = CGPoint.init(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        loadingView.addSubview(actInd)
        
        let progressbar: UIProgressView = UIProgressView()
        progressbar.frame = CGRect.init(x: 0, y: 0, width: loadingView.frame.size.width - 10, height: 2)
        progressbar.trackTintColor = .clear
        progressbar.progressTintColor = UIColor.init(hexString: "#00BDFF")
        progressbar.center = CGPoint.init(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height - 1)
        loadingView.addSubview(progressbar)
        
        containerView.addSubview(loadingView)
        parentView.addSubview(containerView)
        actInd.startAnimating()
        
        return (textDes, progressbar)
    }
    
    func showActivityIndicatoryTitle(title : String)
    {
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
        containerView.tag = 100
        
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect.init(x: 0, y: 0, width: 150, height: 150)
        loadingView.center = view.center
        loadingView.backgroundColor = UIColor.init(red: 68/255, green: 68/255, blue: 68/255, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        
        let textDes = UILabel.init(frame: CGRect(x : 0, y : 0, width : 150, height: 50))
        textDes.textColor = UIColor.white
        textDes.font = UIFont(name:"SegoeUI", size: 15.0)
        textDes.textAlignment = .center
        textDes.numberOfLines = 0
        textDes.center = CGPoint.init(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2 + 45)
        textDes.text = "\(title)..."
        loadingView.addSubview(textDes)
        
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect.init(x: 0, y: 0, width: 40, height: 40)
        actInd.style =
            UIActivityIndicatorView.Style.whiteLarge
        actInd.center = CGPoint.init(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        loadingView.addSubview(actInd)
        containerView.addSubview(loadingView)
        
        parentView.addSubview(containerView)
        actInd.startAnimating()
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
    
    func showActivityIndicatoryCountDown(isRV : Bool, pos : Notification.Name,showCompletion completion: (String) -> Void)
    {
        if !isRV
        {
            let storage = UserDefaults.standard
            if storage.string(forKey: defaultsKeys.APP_REMOVE_ADS) != nil
            {
                completion("removeads")
                return
            }
        }
        else
        {
            completion("loadVideo")
        }
        
        enableAndDisableNaviAndTabbar(isEnable: false)
        
        countTimerShowAds = 1
        
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
        textDes.text = "Loading Ads\n\(countTimerShowAds)..."
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
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: array, repeats: true)
        
        actInd.startAnimating()
    }
    
    @objc func updateTimer(timer: Timer)
    {
        let array : [Any] = timer.userInfo as! [Any]
        countTimerShowAds -= 1
        let txLabel = array[0] as! UILabel
        txLabel.text = "Loading Ads\n\(countTimerShowAds)..."
        if countTimerShowAds <= 0
        {
            timer.invalidate()
            
            enableAndDisableNaviAndTabbar(isEnable: true)
            
            let containerView = array[1] as! UIView
            containerView.removeFromSuperview()
            let posAdsFull = array[2] as! Notification.Name
            NotificationCenter.default.post(name: posAdsFull, object: nil)
            
        }
    }

    func showAlertDialog(title:String? = nil,
                         subtitle:String? = nil,
                         cancelTitle:String? = "Cancel",
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil){
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showConfirmDialog(title:String? = nil,
                           subtitle:String? = nil,
                           actionTitle:String? = "Add",
                           cancelTitle:String? = "Cancel",
                           cancelHandler: ((UIAlertAction) -> Void)? = nil,
                           actionHandler: ((UIAlertAction) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: actionHandler))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Add",
                         cancelTitle:String? = "Cancel",
                         text:String = "",
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        
        alert.addTextField { (textField:UITextField) in
            textField.text = text
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .destructive, handler: cancelHandler))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

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
            bannerView.adUnitID = Constants.BANNER_ID
            bannerView.rootViewController = controller
            bannerView.isAutoloadEnabled = true
            let request = GADRequest()
            bannerView.load(request)
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


var fullRewardAds : GADRewardedInterstitialAd!
func createAndLoadRewardInterstitial() -> Void {
    let storage = UserDefaults.standard
    if storage.string(forKey: defaultsKeys.APP_REMOVE_ADS) == nil
    {
        if !Reachability.isConnectedToNetwork() {return}
        let request = GADRequest()
        GADRewardedInterstitialAd.load(withAdUnitID: Constants.VIDEO_FULL_ID, request: request) { (rewardFull, error) in
            guard error == nil else {
                print("[DEBUG] load ads Full Reward error : \(error?.localizedDescription)")
                return
            }
            fullRewardAds = rewardFull
        }
    }
}

var fullAds : GADInterstitialAd!
func createAndLoadInterstitial() -> Void {
    let storage = UserDefaults.standard
    if storage.string(forKey: defaultsKeys.APP_REMOVE_ADS) == nil
    {
        if !Reachability.isConnectedToNetwork() {return}
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: Constants.FULL_ID, request: request) { ads, error in
            guard error == nil else {
                print("[DEBUG] load ads Full error : \(error?.localizedDescription)")
                return
            }
            fullAds = ads
        }
    }
}

func showAdsInterstitial(_ controller : UIViewController) -> Bool
{
    let storage = UserDefaults.standard
    if storage.string(forKey: defaultsKeys.APP_REMOVE_ADS) != nil
    {
        return false
    }
    
    if(fullAds == nil)
    {
        createAndLoadInterstitial()
        return false
    }
    
    fullAds.present(fromRootViewController: controller)
    return true
}

var rewardAds : GADRewardedAd!
func createAndLoadRewardedAds() -> Void {
    let storage = UserDefaults.standard
    if storage.string(forKey: defaultsKeys.APP_REMOVE_ADS) == nil
    {
        if !Reachability.isConnectedToNetwork() {return}
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: Constants.VIDEO_ID, request: GADRequest()) { ads, error in
            guard error == nil else {
                print("[DEBUG] load ads Reward error : \(error?.localizedDescription)")
                return
            }
            rewardAds = ads
        }
    }
}
