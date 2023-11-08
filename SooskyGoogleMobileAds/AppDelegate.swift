//
//  AppDelegate.swift
//  airplay_stage1
//
//  Created by Tran Tuan Linh on 30/05/2022.
//

import UIKit
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

struct defaultsKeys {
    static let KEY_FIRST_OPEN_APP = "KEY_FIRST_OPEN_APP"
    static let APP_OPENED_COUNT = "APP_OPENED_COUNT"
    static let APP_REMOVE_ADS = "APP_REMOVE_ADS"
    static let APP_SUB_PRO = "APP_SUB_PRO"
    static let APP_IAP_PRO = "APP_IAP_PRO"
    static let APP_INTRO = "APP_INTRO"
}

struct Constants {
    static let App_Specific_Shared_Secret = ""
    
    //*** Ads Test ***
    static let BANNER_ID     = "ca-app-pub-3940256099942544/2934735716"
    static let FULL_ID       =
    [
        "ca-app-pub-3940256099942544/4411468910",
        "ca-app-pub-3940256099942544/4411468910",
        "ca-app-pub-3940256099942544/4411468910"
    ]
    static let VIDEO_FULL_ID = "ca-app-pub-3940256099942544/8691691433"
    static let VIDEO_ID      =
    [
        "ca-app-pub-3940256099942544/5224354917",
        "ca-app-pub-3940256099942544/5224354917",
        "ca-app-pub-3940256099942544/5224354917"
    ]
    static let NATIVE_ID     = "ca-app-pub-3940256099942544/2247696110"
    static let OPEN_ID       =
    [
        "ca-app-pub-3940256099942544/3419835294",
        "ca-app-pub-3940256099942544/3419835294",
        "ca-app-pub-3940256099942544/3419835294"
    ]
    static let APP_ID        = "ca-app-pub-3940256099942544~1458002511"
    //*** Ads Real ***
//    static let BANNER_ID     = ""
//    static let FULL_ID       = ""
//    static let VIDEO_FULL_ID = ""
//    static let VIDEO_ID      = [""]
//    static let NATIVE_ID     = ""
//    static let OPEN_ID       = [""]
//    static let APP_ID        = ""
}

var isOpenSubs : Bool = false
var isCheckTracking : Bool = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var windowSplash: UIWindow?
    var window: UIWindow?
    var appOpenAd: GADAppOpenAd?
    
    var isCheckSub : Bool = false
    var isSetUpAdsSuccess : Bool = false
 
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Check Network Connection
        do {
            try Network.reachability = Reachability(hostname: "www.google.com")
        }
        catch {
            switch error as? Network.Error {
            case let .failedToCreateWith(hostname)?:
                print("Network error:\nFailed to create reachability object With host named:", hostname)
            case let .failedToInitializeWith(address)?:
                print("Network error:\nFailed to initialize reachability object With address:", address)
            case .failedToSetCallout?:
                print("Network error:\nFailed to set callout")
            case .failedToSetDispatchQueue?:
                print("Network error:\nFailed to set DispatchQueue")
            case .none:
                print(error)
            }
        }
        
        self.checkAppTracking()
        if #available(iOS 14, *) {
            if isCheckTracking{
                self.setUpAds()
            }
        } else {
            self.setUpAds()
        }
        
        self.checkSubWhenReturnAppAgain()
        return true
    }
    
    func setUpAds(){
        GADMobileAds.sharedInstance().start()
    }
    
    func checkSubWhenReturnAppAgain(){
        isCheckSub = true
        
        if self.windowSplash == nil{
            self.windowSplash = UIWindow(frame: UIScreen.main.bounds)
        }
        
        windowSplash?.frame = UIScreen.main.bounds
        self.windowSplash?.rootViewController = SplashLoadingVC()
        self.windowSplash?.makeKeyAndVisible()
    }
    
    @available(iOS 14, *)
    func requestIDFA(completion: @escaping (ATTrackingManager.AuthorizationStatus) -> Void) {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            DispatchQueue.main.async {
                self.checkAppTracking()
                self.setUpAds()
                completion(status)
            }
        })
    }
    
    func checkAppTracking(){
        if #available(iOS 14, *) {
            let status = ATTrackingManager.trackingAuthorizationStatus
            switch status {
            case .authorized:
                // Authorized
                isCheckTracking = true
                break
            case .denied:
                isCheckTracking = true
                break
            case .notDetermined:
                isCheckTracking = false
                break
            case .restricted:
                isCheckTracking = false
                break
            @unknown default:
                isCheckTracking = false
                break
            }
        }else{
            isCheckTracking = true
        }
    }
    
    func configVC() {
        isCheckSub = false
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let nameControllerShow = "SooskyTestAdsVC"
        
        if window == nil {
            window = UIWindow(frame: UIScreen.main.bounds)
        }
        
        windowSplash?.frame = CGRect.zero

        
        if isCheckTracking{
            isOpenSubs = false
            let vc = storyBoard.instantiateViewController(withIdentifier: nameControllerShow)
            window?.rootViewController = vc
        }else{
            isOpenSubs = true
            window?.rootViewController = AdsTrackingViewController()
        }
        
        window?.makeKeyAndVisible()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    func configureNavigationBarAppearance() {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = #colorLiteral(red: 0.09411764706, green: 0.09411764706, blue: 0.09411764706, alpha: 1)
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            // Fallback on earlier versions
        }
    }
}

var countTierOpenAds = 0
//Quảng cáo Open Ads
extension AppDelegate : GADFullScreenContentDelegate{
    func requestAppOpenAd() {
        if !Reachability.isConnectedToNetwork(){return}
        let request = GADRequest()
        GADAppOpenAd.load(withAdUnitID: Constants.OPEN_ID[countTierOpenAds],
                          request: request,
                          orientation: UIInterfaceOrientation.portrait,
                          completionHandler: { (appOpenAdIn, error) in
            guard error == nil else {
                print("[DEBUG] load Open Ads error : \(error?.localizedDescription)")
                return
            }
            self.appOpenAd = appOpenAdIn
            self.appOpenAd?.fullScreenContentDelegate = self
            
            if let gOpenAd = self.appOpenAd, let rwc = self.window?.rootViewController {
                gOpenAd.present(fromRootViewController: rwc)
            }
        })
        
        if countTierOpenAds >= Constants.OPEN_ID.count - 1{
            countTierOpenAds = 0
        }else{
            countTierOpenAds += 1
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if UserDefaults.standard.string(forKey: defaultsKeys.APP_REMOVE_ADS) == nil && !isOpenSubs && !isCheckSub{
            self.requestAppOpenAd()
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.appOpenAd = nil
    }
}
