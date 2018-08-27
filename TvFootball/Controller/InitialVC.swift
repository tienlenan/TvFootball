//
//  InitialVC.swift
//  TvFootball
//
//  Created by admin on 8/27/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class InitialVC: UIViewController {
    
    // MARK: - Variables
    let confURL = "https://raw.githubusercontent.com/tienlenan/FileConfig/master/config.json"
    
    // MARK: - Life cycle
    
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadConfig()
    }
    
    // MARK: - Private function
    private func loadConfig() {
        Alamofire.request(confURL, method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
                debugPrint(response)
                var isEnable = false
                if let _ = response.result.error {
                    // Return connection error
                } else {
                    let responseJSONData = JSON(response.result.value!)
                    let statusCode = (response.response?.statusCode)
                    if statusCode == 200 {
                        print("IP: \(responseJSONData)")
                        // Parse data
                        isEnable = responseJSONData["TvFootball"]["enable"].boolValue
                    } else {
                        // Return error from server
                    }
                }
                
                let _ = DataManager.shared
                if isEnable {
                    self.performSegue(withIdentifier: "showMainVCSegue", sender: nil)
                } else {
                    self.performSegue(withIdentifier: "goToBackupVCSegue", sender: nil)
                }
        }
    }
}
