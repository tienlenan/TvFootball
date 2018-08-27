//
//  UserManagerVC.swift
//  TvFootball
//
//  Created by admin on 8/13/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftyJSON

class UserManagerVC: UIViewController, FBSDKLoginButtonDelegate {
    
    // MARK: - IBOutlet
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var coinsLabel: UILabel!
    @IBOutlet weak var expiryDateLabel: UILabel!
    
    // MARK: - Variables
    /// Notification
    let nc = NotificationCenter.default
    
    /// Timer
    var timer: Timer?
    
    // MARK: - Life cycle
    
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup image view
        imageView.layer.cornerRadius = 5
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "profile-img")
        
        // Setup label view
        label.text = ""
        coinsLabel.text = ""
        expiryDateLabel.text = ""
        
        // Setup login button
        let loginButton = FBSDKLoginButton()
        loginButton.center = CGPoint(x: self.view.center.x, y: self.expiryDateLabel.center.y + 50)
        loginButton.delegate = self
        view.addSubview(loginButton)
        
        // Register notification
        nc.addObserver(self, selector: #selector(updateUserInfoSchedule), name: NSNotification.Name(rawValue: TvConstant.shared.USER_INFO_WAS_LOADED), object: nil)
        
        // Schedule timer for update user infor in UI
        self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(updateUserInfoSchedule), userInfo: nil, repeats: true)
    }
    
    
    /// View did appear
    ///
    /// - Parameter animated: animated
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - FBSDKLoginButtonDelegate
    
    /// Did logged out
    ///
    /// - Parameter loginButton: login button object
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        DataManager.shared.fUser = nil
        DataManager.shared.user = nil
        DataManager.shared.streamingMatch = nil
    }
    
    
    /// Did logged in facebook
    ///
    /// - Parameters:
    ///   - loginButton: login button object
    ///   - result: result
    ///   - error: error
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("Logged in facebook...")
    }
    
    /// Update UI schedule timer
    @objc private func updateUserInfoSchedule() {
        guard let user = DataManager.shared.user,
        let fUser = DataManager.shared.fUser else {
            imageView.image = UIImage(named: "profile-img")
            label.text = ""
            coinsLabel.text = ""
            expiryDateLabel.text = ""
            return
        }
        self.label.text = fUser.name
        self.imageView.image = fUser.avatar
        self.coinsLabel.text = "\(user.coins) coins"
        if user.expiryDate > 0 {
            expiryDateLabel.text = "Expiry date of monthly rent:\n\(user.expiryDate.fromIntToDateStr())"
        } else {
            expiryDateLabel.text = ""
        }
    }
}
