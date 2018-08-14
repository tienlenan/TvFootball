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
/// 894971103969882
/// TvFootball

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
    
    /// Current user
    var user: TvUser? = TvUser(uid: 1917019558317843, coins: 200000)
    
    //var user: TvUser? = nil
    
    /// Facebook user
    var fUser: TvFacebookUSer?
    
    /// IP
    var ip: String? = "192.168.1.1"
    
    
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
        let tick = "\(Double(Date().timeIntervalSince1970))"
        let requestURL = TvConstant.GET_STREAM_LINKS_API + "?tick=\(tick)&format=json"
        Alamofire.request(requestURL, method: .post, parameters: parameters, encoding: JSONEncoding.default)
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
    
    
    /// Prepare streaming url
    ///
    /// - Parameter originURL: origin url
    /// - Returns: actual url
    func prepareStreamingURL(_ originURL: String) -> String {
        var actualURL = originURL
        if actualURL.contains(find: "token") {
            actualURL = String(actualURL.split(separator: "?").first!)
            let tick = String(Date().timeIntervalSince1970 + 7000)
            let t3 = ("livestream" + self.ip! + tick)
                .data(using: String.Encoding.utf8)?.base64EncodedString() ?? ""
            actualURL = actualURL
                + "?token="
                + t3.replacingOccurrences(of: "=", with: "")
                    .replacingOccurrences(of: "+", with: "-")
                    .replacingOccurrences(of: "/", with: "_")
                + "&e=" + tick
        }
        return actualURL
    }
    
    
    func decrypt(input: String, key: String) -> String {
//        var encrypted: String!
//        do {
//            // In combined mode, the authentication tag is directly appended to the encrypted message. This is usually what you want.
//            let iv: Array<UInt8> = AES.randomIV(AES.blockSize)
//            let gcm = GCM(iv: iv, mode: .combined)
//            let aes = try AES(key: Array(key.utf8), blockMode: gcm, padding: .noPadding)
//            let cipherText = try aes.decrypt(Array(input.utf8))
//            encrypted = String(bytes: cipherText, encoding: .utf8)
//            if let data = NSData(base64Encoded: encrypted, options: NSData.Base64DecodingOptions(rawValue: 0)) {
//                encrypted = String(data: data as Data, encoding: String.Encoding.utf8)
//            }
//            return encrypted
//        } catch {
//            // failed
//        }
        
        let inputBytes: Array<UInt8> = Array(input.utf8)
        
        let keyBytes: Array<UInt8> = Array(key.utf8)
        let iv: Array<UInt8> = AES.randomIV(AES.blockSize)
        
        do {
            let decrypted = try AES(key: keyBytes, blockMode: CBC(iv: iv), padding: .pkcs7).decrypt(inputBytes)
            if let data = NSData(base64Encoded: decrypted, options: NSData.Base64DecodingOptions(rawValue: 0)) {
                return String(data: data as Data, encoding: String.Encoding.utf8)!
            }
            return ""
        } catch {
            print(error)
        }
        
        return ""
    }

    
}
