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

class UserManagerVC: UIViewController, FBSDKLoginButtonDelegate {
    
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
        if(FBSDKAccessToken.current() != nil)
        {
            //print permissions, such as public_profile
            print(FBSDKAccessToken.current().permissions)
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"])
            let connection = FBSDKGraphRequestConnection()
            
            connection.add(graphRequest, completionHandler: { (connection, result, error) -> Void in
                
                let data = result as! [String : AnyObject]
                
                self.label.text = data["name"] as? String
                
                let FBid = data["id"] as? String
                
                let url = NSURL(string: "https://graph.facebook.com/\(FBid!)/picture?type=large&return_ssl_resources=1")
                self.imageView.image = UIImage(data: NSData(contentsOf: url! as URL)! as Data)
            })
            connection.start()
        }
    }
}
