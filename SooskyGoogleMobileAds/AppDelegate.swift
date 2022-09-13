//
//  AppDelegate.swift
//  airplay_stage1
//
//  Created by Tran Tuan Linh on 30/05/2022.
//

import UIKit
import GoogleMobileAds
import Firebase
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
    static let BANNER_ID =
//            ""
        "ca-app-pub-3940256099942544/2934735716"
    static let FULL_ID =
//            ""
        "ca-app-pub-3940256099942544/4411468910"
    static let VIDEO_FULL_ID =
//    ""
    "ca-app-pub-3940256099942544/6978759866"
    static let VIDEO_ID =
//            ""
        "ca-app-pub-3940256099942544/5224354917"
    static let NATIVE_ID =
//                ""
        "ca-app-pub-3940256099942544/2247696110"
    static let OPEN_ID =
//    ""
    "ca-app-pub-3940256099942544/3419835294"
    static let APP_ID =
//            ""
        "ca-app-pub-3940256099942544~1458002511"
}

var isOpenSubs : Bool = false
var isCheckTracking : Bool = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , GADFullScreenContentDelegate {
    
    var window: UIWindow?
    var extWindow : UIWindow?
    var appOpenAd: GADAppOpenAd?
    var loadTime = Date()
 
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
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        self.checkAppTracking()
        return true
    }
    
    @available(iOS 14, *)
    func requestIDFA(completion: @escaping (ATTrackingManager.AuthorizationStatus) -> Void) {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            DispatchQueue.main.async {
                self.checkAppTracking()
                completion(status)
                
                switch status {
                case .authorized:
                    // Authorized
                    let idfa = ASIdentifierManager.shared().advertisingIdentifier
                    print("[DEBUG] idfa \(idfa)")
//                        self.label.text = idfa.uuidString
                case .denied,
                        .notDetermined,
                        .restricted:
                    break
                @unknown default:
                    break
                }
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
    
    func configVC() {
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let nameControllerShow = "SooskyAdsVC"
        
        if window == nil {
            window = UIWindow(frame: UIScreen.main.bounds)
            return
        }
        
        if isCheckTracking{
            let vc = storyBoard.instantiateViewController(withIdentifier: nameControllerShow)
            window?.rootViewController = vc
        }else{
            window?.rootViewController = AdsTrackingViewController()
        }
        
        window?.makeKeyAndVisible()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }
}

//Quảng cáo Open Ads
extension AppDelegate{
    func requestAppOpenAd() {
        let request = GADRequest()
        GADAppOpenAd.load(withAdUnitID: Constants.OPEN_ID,
                          request: request,
                          orientation: UIInterfaceOrientation.portrait,
                          completionHandler: { (appOpenAdIn, error) in
            guard error == nil else {
                print("[DEBUG] load Open Ads error : \(error?.localizedDescription)")
                return
            }
            self.appOpenAd = appOpenAdIn
            self.appOpenAd?.fullScreenContentDelegate = self
            self.loadTime = Date()
        })
    }

    func tryToPresentAd() {
        let storage = UserDefaults.standard
        if storage.string(forKey: defaultsKeys.APP_REMOVE_ADS) != nil
        {
            return
        }
        
        //Khi ở màn hình sub thì ko hiện ads
        if let gOpenAd = self.appOpenAd, let rwc = self.window?.rootViewController, !isOpenSubs {
            //Quảng cáo open ads sẽ hiển thị cứ 4 tiếng 1 lần
            if wasLoadTimeLessThanNHoursAgo(thresholdN: 4){
                gOpenAd.present(fromRootViewController: rwc)
            }
        } else {
            if self.appOpenAd == nil{
                self.requestAppOpenAd()
            }
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        self.tryToPresentAd()
    }

    func wasLoadTimeLessThanNHoursAgo(thresholdN: Int) -> Bool {
        let now = Date()
        let timeIntervalBetweenNowAndLoadTime = now.timeIntervalSince(self.loadTime)
        let secondsPerHour = 3600.0
        let intervalInHours = timeIntervalBetweenNowAndLoadTime / secondsPerHour
        return intervalInHours < Double(thresholdN)
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.appOpenAd = nil
    }
}
