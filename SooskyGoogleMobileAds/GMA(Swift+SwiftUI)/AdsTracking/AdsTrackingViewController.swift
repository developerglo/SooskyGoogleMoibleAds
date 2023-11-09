//
//  AdsTrackingViewController.swift
//  BeatMaker
//
//  Created by Soosky CTO on 16/08/2022.
//

import UIKit

class AdsTrackingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func showPopupAdsTracking(){
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        if #available(iOS 14, *) {
            appDelegate.requestIDFA { status in
                self.showVC()
            }
        } else {
            // Fallback on earlier versions
            self.showVC()
        }
    }
    
    @IBAction func btnAllowClick(_ sender: UIButton) {
        self.showPopupAdsTracking()
    }
    
    func showVC(){
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.configVC()
    }
    
    @IBAction func btnDontAllowClick(_ sender: UIButton) {
        self.showPopupAdsTracking()
    }
}
