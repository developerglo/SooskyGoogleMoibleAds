//
//  SooskyTestAdsVC.swift
//  SooskyGoogleMobileAds
//
//  Created by Soosky CTO on 12/09/2022.
//

import UIKit
import GoogleMobileAds

//Khởi tạo biến count Ads Full  ở ngoài class
var countFullAdsSoosky : Int = 0

class SooskyTestAdsVC: BaseViewController {

    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var heightConstraintBannerView: NSLayoutConstraint!
    
    //Tắt quảng cáo ads
    override func turnOffAds() {
        print("[DEBUG] Đóng quảng cáo")
    }
    
    //Tắt quảng cáo ads Reward và Reward 10s có thưởng
    override func haveReward() {
        print("[DEBUG] Đóng quảng cáo khi có thưởng")
    }
    
    //Tắt quảng cáo ads Reward và Reward 10s không thưởng
    override func dontHaveReward() {
        print("[DEBUG] Đóng quảng cáo khi không thưởng")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bannerView = createAndLoadBanner(bannerView, self, heightConstraintBannerView)
    }
    
    func showPopupConfirmToShowRewardAds(_ title : String, _ subTitle : String){
        self.showConfirmDialog(title: title, subtitle: subTitle, actionTitle: "YES", cancelTitle: "NO") { no in
            
        } actionHandler: { yes in
            self.showPopupLoadingAds(ADS_POS.POS_REWARD)
        }
    }
    
    func showPopupConfirmToShowRewardAds10s(_ title : String, _ subTitle : String){
        self.showConfirmDialog(title: title, subtitle: subTitle, actionTitle: "YES", cancelTitle: "NO") { no in
            
        } actionHandler: { yes in
            self.showPopupLoadingAds(ADS_POS.POS_FULL_REWARD)
        }
    }
    
    //MARK: - Button Action
    @IBAction func showAdsFull(_ sender: UIButton) {
        showPopupLoadingAds(.POS_FULL)
    }
    
    @IBAction func showAdsReward10s(_ sender: UIButton) {
        self.showPopupConfirmToShowRewardAds10s("Watch Ads", "Are you sure to watch ads to have coin?")
    }
    
    @IBAction func showAdsReward(_ sender: UIButton) {
        self.showPopupConfirmToShowRewardAds("Watch Ads", "Are you sure to watch ads to have coin?")
    }
    
    //Tương tác 3 lần đầu tiên hiển thị quảng cáo full, sau đó tương tác 5 lần mới hiển thị quảng cáo và lặp lại
    @IBAction func countToShowAds1(_ sender: UIButton) {
        countAdsToShowVC(3, 5, &countFullAdsSoosky)
    }
    
    @IBAction func countToShowAds2(_ sender: UIButton) {
       countAdsToShowVC(3, 5, &countFullAdsSoosky)
    }
    
    @IBAction func countToShowAds3(_ sender: UIButton) {
        countAdsToShowVC(3, 5, &countFullAdsSoosky)
    }
}
