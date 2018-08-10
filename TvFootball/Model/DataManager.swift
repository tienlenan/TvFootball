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

let BANNER_IMAGE_URL = "https://i.imgur.com/QZ6j8Mg.png"
let DEFAULT_TEAM_IMG = "tv-logo"

enum HTTPResult {
    case httpSuccess, httpErrorFromServer, httpConnectionError
}

class DataManager: NSObject {
    static let shared: DataManager = DataManager()
    weak var delegate: HTTPDelegate?
    var liveMatches: [LiveMatch] = []
    var streamURLs: [String] = []
    var mainTabBarVC: TvFootballVC!
    var streamingMatch: LiveMatch?
    
    /// Handle response from server
    ///
    /// - Parameters:
    ///   - type: result type success/error from server/connection error
    ///   - data: response data
    private func handleResponse(type: HTTPResult, data: JSON?) {
        if type == .httpSuccess {
            self.delegate?.didGetSuccessRespond(data: data)
        } else if type == .httpErrorFromServer {
            self.delegate?.didGetErrorFromServer(message: "Error from server.")
        } else {
            self.delegate?.didGetConnectionError(message: "Connection error.")
        }
        
        self.delegate = nil
    }
    
    /// Get live matches
    ///
    /// - Parameter httpDelegate: delegate
    func getLiveMatches(_ httpDelegate: HTTPDelegate?) {
        self.delegate = httpDelegate
        let requestURL = "http://api.bongdahd.info/api/fixture/list"
        Alamofire.request(requestURL, encoding: JSONEncoding.default)
            .responseJSON { response in
                debugPrint(response)
                if let _ = response.result.error {
                    // Return connection error
                    self.handleResponse(type: .httpConnectionError, data: nil)
                    
                } else {
                    let responseJSONData = JSON(response.result.value!)
                    let statusCode = (response.response?.statusCode)
                    if statusCode == 200 {
                        // Parse data
                        self.liveMatches = []
                        let matchesDataJSON = responseJSONData["result"]
                        for i in 0..<matchesDataJSON.count {
                            let match = LiveMatch.init(jsonData: matchesDataJSON[i])
                            self.liveMatches.append(match)
                        }
                        
                        // Return http success
                        self.handleResponse(type: .httpSuccess, data: responseJSONData)
                        
                    } else {
                        // Return error from server
                        self.handleResponse(type: .httpConnectionError, data: nil)
                    }
                }
        }
    }
    
    /// Get stream urls
    ///
    /// - Parameter httpDelegate: delegate
    func getStreamUrls(_ httpDelegate: HTTPDelegate?, liveMatchId: Int) {
        self.delegate = httpDelegate
        self.handleResponse(type: .httpSuccess, data: [])
        /*
        let requestURL = "stream url"
        Alamofire.request(requestURL, encoding: JSONEncoding.default)
            .responseJSON { response in
                debugPrint(response)
                if let _ = response.result.error {
                    // Return connection error
                    self.handleResponse(type: .httpConnectionError, data: nil)
                    
                } else {
                    let responseJSONData = JSON(response.result.value!)
                    let statusCode = (response.response?.statusCode)
                    if statusCode == 200 {
                        // Parse data
                        
                        // Return http success
                        self.handleResponse(type: .httpSuccess, data: responseJSONData)
                        
                    } else {
                        // Return error from server
                        self.handleResponse(type: .httpConnectionError, data: nil)
                    }
                }
        }
        */
    }
}
