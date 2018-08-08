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
    weak var delegate: HTTPDelegate?
    var liveMatches: [LiveMatch] = []
    
    /// Get live matches
    func getLiveMatches() {
        self.liveMatches = []
        let requestURL = "http://api.bongdahd.info/api/fixture/list"
        Alamofire.request(requestURL, encoding: JSONEncoding.default)
            .responseJSON { response in
                debugPrint(response)
                if let _ = response.result.error {
                    // Connection error
                    print("Connection error...")
                    self.delegate?.didGetConnectionError(message: "Connection error.")
                } else { // No errors
                    let responseJSONData = JSON(response.result.value!)
                    let statusCode = (response.response?.statusCode)
                    if statusCode == 200 {
                        print("Live Data: \(responseJSONData)")
                        let matchesDataJSON = responseJSONData["result"]
                        for i in 0..<matchesDataJSON.count {
                            let match = LiveMatch.init(jsonData: matchesDataJSON[i])
                            self.liveMatches.append(match)
                        }
                        print("Length: \(self.liveMatches.count)")
                        
                        self.delegate?.didGetSuccessRespond(data: responseJSONData)
                    } else {
                        // Error from server
                        print("Error from server...")
                        self.delegate?.didGetErrorFromServer(message: "Error from server.")
                    }
                }
        }
    }
}
