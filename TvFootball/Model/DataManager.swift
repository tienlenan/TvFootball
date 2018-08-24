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
import CryptoSwift
import FBSDKCoreKit
import FBSDKLoginKit

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
    
    /// Current user
    var user: TvUser?
    
    /// Facebook user
    var fUser: TvFacebookUSer?
    
    /// IP
    var ip: String?
    
    // Timer
    var timer: Timer?
    
    // Notification center
    let nc = NotificationCenter.default
    
    // User state
    lazy var userState: TvUSerState = TvUSerState.loggedOut
    
    
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
    
    override init() {
        super.init()
        self.getUserInfoSchedule()
        self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(getUserInfoSchedule), userInfo: nil, repeats: true)
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
                        self.liveMatches = self.liveMatches.sorted(by: { $0.startDate < $1.startDate })
                        
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
    /// Purpose
    /// - 1. Get streaming links of match
    /// - 2. Check match is bought or not
    ///
    /// - Parameters:
    ///   - httpDelegate: delegate
    ///   - liveMatchId: live match identifier
    ///   - userId: id of user who wants to watch match
    func getStreamUrls(_ httpDelegate: HTTPDelegate?, liveMatchId: Int, userId: Int) {
        self.delegate = httpDelegate
        
        let parameters: [String:Any] = [
            "LiveMatchId": liveMatchId,
            "UserId": userId
        ]
        let tick = "\(Int(Date().timeIntervalSince1970))"
        let xAuthHeader = (tick + ",test,an").aesAndBase64Encrypt(key: TvConstant.AES_KEY) ?? ""
        
        let headers: HTTPHeaders = [
            "X-AUTH-API": xAuthHeader,
            "Accept": "application/json"
        ]
        let requestURL = TvConstant.GET_STREAM_LINKS_API + "?tick=\(tick)&format=json"
        Alamofire.request(requestURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
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
                        print("Links: \(responseJSONData)")
                        
                        // Return http success
                        self.handleResponse(type: .httpSuccess, data: responseJSONData)
                        
                    } else {
                        // Return error from server
                        self.handleResponse(type: .httpConnectionError, data: nil)
                    }
                }
        }
    }
    
    /// Buy streaming match
    /// Purpose
    /// - Get streaming links of match
    ///
    /// - Parameters:
    ///   - httpDelegate: delegate
    ///   - liveMatchId: live match identifier
    ///   - userId: id of user who wants to buy match
    func buyStreamingMatch(_ httpDelegate: HTTPDelegate?, liveMatchId: Int, userId: Int) {
        self.delegate = httpDelegate
        
        let parameters: [String:Any] = [
            "LiveMatchId": liveMatchId,
            "UserId": userId
        ]
        Alamofire.request(TvConstant.TRY_GET_STREAM_LINKS_API, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                debugPrint(response)
                if let _ = response.result.error {
                    // Return connection error
                    self.handleResponse(type: .httpConnectionError, data: nil)
                    
                } else {
                    let responseJSONData = JSON(response.result.value!)
                    let statusCode = (response.response?.statusCode)
                    if statusCode == 200 {
                        // Return http success
                        self.handleResponse(type: .httpSuccess, data: responseJSONData)
                        
                    } else {
                        // Return error from server
                        self.handleResponse(type: .httpConnectionError, data: nil)
                    }
                }
        }
    }
    
    /// Get live matches
    ///
    /// - Parameter httpDelegate: delegate
    func getDeviceIP(_ httpDelegate: HTTPDelegate?) {
        self.delegate = httpDelegate
        Alamofire.request(TvConstant.IP_TRACKING_URL, method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
                debugPrint(response)
                if let _ = response.result.error {
                    // Return connection error
                    self.handleResponse(type: .httpConnectionError, data: nil)
                    
                } else {
                    let responseJSONData = JSON(response.result.value!)
                    let statusCode = (response.response?.statusCode)
                    if statusCode == 200 {
                        print("IP: \(responseJSONData)")
                        // Parse data
                        self.ip = responseJSONData["IP"].string
                        
                        // Return http success
                        self.handleResponse(type: .httpSuccess, data: responseJSONData)
                        
                    } else {
                        // Return error from server
                        self.handleResponse(type: .httpConnectionError, data: nil)
                    }
                }
        }
    }
    
    func getUSerInfo(_ httpDelegate: HTTPDelegate?, fUser: TvFacebookUSer) {
        self.delegate = httpDelegate
        
        let parameters: [String:Any] = [
            "id": fUser.fid,
            "name": fUser.name,
            "email": fUser.email
        ]
        let tick = "\(Int(Date().timeIntervalSince1970))"
        let xAuthHeader = (tick + ",test,an").aesAndBase64Encrypt(key: TvConstant.AES_KEY) ?? ""
        
        let headers: HTTPHeaders = [
            "X-AUTH-API": xAuthHeader,
            "Accept": "application/json"
        ]
        let requestURL = TvConstant.GET_USER_INFO_API + "?tick=\(tick)&format=json"
        Alamofire.request(requestURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
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
                        print("User info: \(responseJSONData)")
                        
                        guard let id = Int(responseJSONData["id"].stringValue) else {
                            return
                        }
                        
                        let user = TvUser(uid: id)
                        self.user = user
                        
                        if httpDelegate == nil {
                            // Notify to UserManagerVC
                            self.nc.post(name: NSNotification.Name(rawValue: TvConstant.USER_INFO_WAS_LOADED), object: nil)
                        } else {
                            // Return http success
                            self.handleResponse(type: .httpSuccess, data: responseJSONData)
                        }
                        
                    } else {
                        // Return error from server
                        self.handleResponse(type: .httpConnectionError, data: nil)
                    }
                }
        }
    }
    
    
    /// Get user information per 5s
    @objc private func getUserInfoSchedule() {
        // Check access token
        if FBSDKAccessToken.current() == nil {
            // If empty
            // User logged out from server
            userState = TvUSerState.loggedOut
        } else {
            if let fbUser = fUser {
                // Logged in facebook
                if let _ = user {
                    // Information was loaded
                    userState = TvUSerState.informtionLoaded
                } else {
                    // Information was not loaded
                    userState = TvUSerState.informationNotLoaded
                }
                
                // Get user infor
                getUSerInfo(nil, fUser: fbUser)
                
            } else {
                // If not empty
                // Continue get information
                getFacebookUserInfo()
                
                // Information was not loaded
                userState = TvUSerState.informationNotLoaded
            }
        }
    }
    
    func getFacebookUserInfo() {
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"])
        let connection = FBSDKGraphRequestConnection()
        
        connection.add(graphRequest, completionHandler: { (connection, result, error) -> Void in
            guard let data = result as? [String : AnyObject] else {
                return
            }
            
            guard let id = data["id"] as? String else {
                    return
            }
            
            let name = (data["name"] as? String) ?? ""
            let email = (data["email"] as? String) ?? ""
            
            let url = NSURL(string: "https://graph.facebook.com/\(id)/picture?type=large&return_ssl_resources=1")
            let avatar = UIImage(data: NSData(contentsOf: url! as URL)! as Data)
            let fUser: TvFacebookUSer = TvFacebookUSer(fid: id,
                                                       email: email,
                                                       name: name,
                                                       avatar: avatar)
            
            // Set current facebook user
            self.fUser = fUser
            
            // Get user info from bongdahd
            self.getUSerInfo(nil, fUser: fUser)
        })
        connection.start()
        
    }
    
    /// Prepare streaming url
    ///
    /// - Parameter originURL: origin url
    /// - Returns: actual url
    func prepareStreamingURL(_ originURL: String) -> String {
        var actualURL = originURL
        if actualURL.contains(find: "token") {
            actualURL = String(actualURL.split(separator: "?").first!)
            let tick = String(Int(Date().timeIntervalSince1970 + 7000))
            let t3 = ("livestream" + self.ip! + tick).bytes.md5().toBase64() ?? ""
            actualURL = actualURL
                + "?token="
                + t3.replacingOccurrences(of: "=", with: "")
                    .replacingOccurrences(of: "+", with: "-")
                    .replacingOccurrences(of: "/", with: "_")
                + "&e=" + tick
        }
        return actualURL
    }
    
    /// Decrypt data
    ///
    /// - Parameters:
    ///   - input: input data which want to decrypt
    ///   - key: key
    /// - Returns: decrypted data
    func decrypt(input: String, key: String) -> String {
        if let actualStr = input.aesAndBase64Decript(key: TvConstant.AES_KEY) {
            return actualStr
        }
        return ""
    }
}
