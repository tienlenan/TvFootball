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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 5
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "profile-img")
        
        label.text = "Non-user"
        label.textAlignment = NSTextAlignment.center
        
        let loginButton = FBSDKLoginButton()
        loginButton.center = self.view.center
        loginButton.delegate = self
        view.addSubview(loginButton)
        
        getFacebookUserInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let user = DataManager.shared.user {
            self.coinsLabel.text = "\(user.coins) coins"
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("loginButtonDidLogOut")
        imageView.image = UIImage(named: "profile-img")
        label.text = "Non-user"
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("didCompleteWith")
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
                    AppUtility.showErrorMessage("Can't get user data!")
                    return
                }
                
                let fUser = TvFacebookUSer(fid: (data["id"] as? String) ?? "",
                                           email: (data["email"] as? String) ?? "",
                                           name: (data["name"] as? String) ?? "")
                
                self.label.text = fUser.name
                
                let FBid = fUser.fid
                
                let url = NSURL(string: "https://graph.facebook.com/\(FBid)/picture?type=large&return_ssl_resources=1")
                self.imageView.image = UIImage(data: NSData(contentsOf: url! as URL)! as Data)
                
                DataManager.shared.fUser = fUser
                
                // Get user info from bongdahd
                DataManager.shared.getUSerInfo(self, fUser: fUser)
            })
            connection.start()
        }
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
        
    }
    
    func didGetConnectionError(message: String) {
        print("Error")
        
    }
}
