//
//  DataManager.swift
//  TvFootball
//
//  Created by Le Tien An on 8/8/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class DataManager: NSObject {
    static let shared: DataManager = DataManager()
    
    func getLiveMatches() {
        let requestURL = "http://api.bongdahd.info/api/fixture/list"
        Alamofire.request(requestURL, encoding: JSONEncoding.default)
            .responseJSON { response in
                debugPrint(response)
                if let httpError = response.result.error {
                    // Connection error
                    print("Connection error...")
                } else { // No errors
                    let responseJSONData = JSON(response.result.value!)
                    let statusCode = (response.response?.statusCode)
                    if statusCode == 200 {
                        print("test: \(responseJSONData)")
                    } else {
                        // Error from server
                        print("Error from server...")
                    }
                }
        }
    }
}
