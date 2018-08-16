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

class UserManagerVC: UIViewController, FBSDKLoginButtonDelegate, HTTPDelegate {
    
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var coinsLabel: UILabel!
    
    let nc = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup image view
        imageView.layer.cornerRadius = 5
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "profile-img")
        
        // Setup label view
        label.text = "Non-user"
        label.textAlignment = NSTextAlignment.center
        
        // Setup login button
        let loginButton = FBSDKLoginButton()
        loginButton.center = self.view.center
        loginButton.delegate = self
        view.addSubview(loginButton)
        
        // Get fb user info
        getFacebookUserInfo()
        
        // Register notification
        nc.addObserver(self, selector: #selector(userInfoLoaded), name: NSNotification.Name(rawValue: TvConstant.USER_INFO_WAS_LOADED), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let user = DataManager.shared.user {
            self.coinsLabel.text = "\(user.coins) coins"
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        imageView.image = UIImage(named: "profile-img")
        label.text = "Non-user"
        DataManager.shared.fUser = nil
        DataManager.shared.user = nil
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        getFacebookUserInfo()
    }
    
    func getFacebookUserInfo() {
        if FBSDKAccessToken.current() != nil {
            //print permissions, such as public_profile
            print(FBSDKAccessToken.current().permissions)
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"])
            let connection = FBSDKGraphRequestConnection()
            
            connection.add(graphRequest, completionHandler: { (connection, result, error) -> Void in
                guard let data = result as? [String : AnyObject] else {
                    AppUtility.showErrorMessage("Can't get your facebook information!")
                    return
                }
                
                guard let id = data["id"] as? String,
                    let name = data["name"] as? String,
                    let email = data["email"] as? String else {
                        return
                }
                let url = NSURL(string: "https://graph.facebook.com/\(id)/picture?type=large&return_ssl_resources=1")
                let avatar = UIImage(data: NSData(contentsOf: url! as URL)! as Data)
                let fUser: TvFacebookUSer = TvFacebookUSer(fid: id,
                                           email: email,
                                           name: name,
                                           avatar: avatar)
                
                DataManager.shared.fUser = fUser
                self.label.text = fUser.name
                self.imageView.image = fUser.avatar
                
                // Get user info from bongdahd
                DataManager.shared.getUSerInfo(self, fUser: fUser)
            })
            connection.start()
        }
    }
    
    @objc private func userInfoLoaded() {
        guard let user = DataManager.shared.user,
        let fUser = DataManager.shared.fUser else {
            return
        }
        self.label.text = fUser.name
        self.imageView.image = fUser.avatar
        self.coinsLabel.text = "\(user.coins) coins"
    }
    
    // MARK: - HTTPDelegate
    
    func didGetSuccessRespond(data: JSON?) {
        guard let _ = data else {
            return
        }
        
        if let coins = DataManager.shared.user?.coins {
            self.coinsLabel.text = "\(coins) coins"
        }
        
    }
    
    func didGetErrorFromServer(message: String) {
        print("Error")
        AppUtility.showErrorMessage("Can't get your account information from TvFootball!")
    }
    
    func didGetConnectionError(message: String) {
        print("Error")
        AppUtility.showErrorMessage("Can't get your account information from TvFootball!")
    }
}
