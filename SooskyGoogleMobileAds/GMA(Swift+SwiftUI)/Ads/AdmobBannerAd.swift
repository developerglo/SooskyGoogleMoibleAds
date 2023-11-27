//
//  AdmobBannerAd.swift
//  SooskyGoogleMobileAds
//
//  Created by Posu on 27/11/2023.
//

import Foundation
import UIKit
import GoogleMobileAds

class AdmobBannerAd : UIView, GADBannerViewDelegate{
    lazy private var spinnerView: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.color = UIColor.black
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    private var bannerView: GADBannerView?
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
    }
    
    private func showSpinnerView() {
        addSubview(spinnerView)
        spinnerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        spinnerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        spinnerView.startAnimating()
    }
    
    private func hiddenSpinnerView() {
        spinnerView.stopAnimating()
        spinnerView.removeFromSuperview()
    }
    
    func loadingAds(height: CGFloat = 50) {
        if !Reachability.isConnectedToNetwork() {
            hiddenAds()
            return
        }
        
        if UserDefaults.standard.string(forKey: defaultsKeys.APP_REMOVE_ADS) == nil {
            showAds(height: height)
        } else {
            hiddenAds()
        }
    }
    
    func showAds(height: CGFloat) {
        showSpinnerView()
        bannerView?.removeFromSuperview()
        bannerView = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: UIScreen.main.bounds.width, height: height)))
        bannerView?.adUnitID = Constants.BANNER_ID
        bannerView?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bannerView ?? UIView())
        bannerView?.delegate = self
        bannerView?.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bannerView?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bannerView?.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bannerView?.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bannerView?.heightAnchor.constraint(equalToConstant: height).isActive = true
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        bannerView?.rootViewController = appDelegate.window?.rootViewController
        bannerView?.load(GADRequest())
    }
    
    func hiddenAds() {
        hiddenSpinnerView()
        bannerView?.removeFromSuperview()
//        self.heightA
        self.layoutIfNeeded()
       
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        hiddenSpinnerView()
    }
}
