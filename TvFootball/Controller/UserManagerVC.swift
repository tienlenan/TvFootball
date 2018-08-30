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
import SwiftMessages

class UserManagerVC: UIViewController, FBSDKLoginButtonDelegate, HTTPDelegate {
    
    // MARK: - IBOutlet
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var coinsLabel: UILabel!
    @IBOutlet weak var expiryDateLabel: UILabel!
    @IBOutlet weak var buyMonthButton: UIButton!
    
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
        
        // Setup buy month button
        buyMonthButton.layer.cornerRadius = 2
        buyMonthButton.layer.borderWidth = 2
        buyMonthButton.layer.borderColor = UIColor.clear.cgColor
        buyMonthButton.isHidden = true
        
        // Setup label view
        label.text = ""
        coinsLabel.text = ""
        expiryDateLabel.text = ""
        
        // Setup login button
        let loginButton = FBSDKLoginButton()
        loginButton.center = CGPoint(x: self.view.center.x, y: self.view.frame.height - 80)
        loginButton.delegate = self
        view.addSubview(loginButton)
        
        // Register notification
        nc.addObserver(self, selector: #selector(updateUserInfoSchedule), name: NSNotification.Name(rawValue: TvConstant.USER_INFO_WAS_LOADED), object: nil)
        
        // Schedule timer for update user infor in UI
        self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(updateUserInfoSchedule), userInfo: nil, repeats: true)
    }
    // MARK: - IBAction
    @IBAction func tapBuyMonthButton(_ sender: Any) {
        guard let user = DataManager.shared.user else {
            return
        }
        
        // Check coins
        if user.coins > 20000 {
            // Show confirm message, asked user want to buy match or not
            // If user tap OK -> Get links
            // If user tap Cancel -> Dismiss popup
            let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
            messageView.configureBackgroundView(width: 290)
            messageView.configureContent(title: "TvFootball", body: "Press 'Yes' to buy monthly service. If you don't want, please try swiping to dismiss this message.", iconImage: nil, iconText: "🦄", buttonImage: nil, buttonTitle: "Yes") { _ in
                DataManager.shared.buyMonth(self, userId: user.uid)
                SwiftMessages.hide()
            }
            messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
            messageView.backgroundView.layer.cornerRadius = 10
            var config = SwiftMessages.defaultConfig
            config.presentationStyle = .center
            config.duration = .forever
            config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
            config.presentationContext  = .window(windowLevel: UIWindowLevelStatusBar)
            SwiftMessages.show(config: config, view: messageView)
        } else {
            AppUtility.showErrorMessage("Do not enough to buy month, your account must has at least 20k coins!")
        }
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
            buyMonthButton.isHidden = true
            return
        }
        self.label.text = fUser.name
        self.imageView.image = fUser.avatar
        self.coinsLabel.text = "\(user.coins) coins"
        if user.expiryDate > 0 {
            expiryDateLabel.text = "Expiry date of monthly rent:\n\(user.expiryDate.fromIntToDateStr())"
            buyMonthButton.isHidden = true
        } else {
            expiryDateLabel.text = ""
            buyMonthButton.isHidden = false
        }
    }
    
    // MARK: - HTTPDelegate
    func didGetSuccessRespond(data: JSON?) {
        AppUtility.showSuccessMessage("Now you can watch all of the matches in one month!")
    }
    
    func didGetErrorFromServer(message: String) {
        AppUtility.showErrorMessage("Something is horribly wrong from server!")
    }
    
    func didGetConnectionError(message: String) {
        AppUtility.showErrorMessage("Please check your network connection!")
    }
}
