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
    
    let defaults = UserDefaults.standard
    let fileManager = FileManager.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
