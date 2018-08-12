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

enum HTTPResult {
    case httpSuccess, httpErrorFromServer, httpConnectionError
}

class DataManager: NSObject {
    static let shared: DataManager = DataManager()
    weak var delegate: HTTPDelegate?
    
    /// List of streaming match
    var liveMatches: [LiveMatch] = []
    
    /// Streaming urls for current match
    var streamURLs: [String] = []
    
    /// Main view controller
    var mainTabBarVC: TvFootballVC!
    
    /// Current match
    var streamingMatch: LiveMatch?
    
    /// List of bought match
    var boughtMatches: [Int] = []
    
    ///
    var user: TvUser? = TvUser(uid: 1917019558317843, coins: 200000)
    
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
        Alamofire.request(TvConstant.GET_LIVE_MATCHES_API_URL, encoding: JSONEncoding.default)
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
                        
                        // Sorted array by league name
                        self.liveMatches = self.liveMatches.sorted(by: { $0.tournamentName > $1.tournamentName })
                        
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
    /// - Parameters:
    ///   - httpDelegate: delegate
    ///   - liveMatchId: live match identifier
    func getStreamUrls(_ httpDelegate: HTTPDelegate?, liveMatchId: Int) {
        self.delegate = httpDelegate
        
        let parameters: [String:Any] = [
            "LiveMatchId": liveMatchId,
            "UserId": "1917019558317843"
        ]
        Alamofire.request(TvConstant.GET_STREAM_LINKS_API,method: .post, parameters: parameters, encoding: JSONEncoding.default)
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
                        print("links: \(responseJSONData)")
                        // Return http success
                        self.handleResponse(type: .httpSuccess, data: responseJSONData)
                        
                    } else {
                        // Return error from server
                        self.handleResponse(type: .httpConnectionError, data: nil)
                    }
                }
        }
    }
}
