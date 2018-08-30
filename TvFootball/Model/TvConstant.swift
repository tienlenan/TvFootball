//
//  TvConstant.swift
//  TvFootball
//
//  Created by admin on 8/11/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import Foundation

class TvConstant {
    /// Banner image url
    static let TOP_BANNER_IMAGE_URL = "http://nghienbongda.net/topfunlive1.gif"
    static let BOTTOM_BANNER_IMAGE_URL = "http://nghienbongda.net/bottomfunlive1.gif"
    
    /// Ads web url
    static let ADS_URL = "http://nghienbongda.net/iframe/index.php"
    
    /// For getting live matches url
    static let GET_LIVE_MATCHES_API_URL = "http://api.bongdahd.info/api/fixture/list"
    
    /// For get streaming links
    /// If bought, return links
    /// If not bought, return "NotBought" in response
    static let GET_STREAM_LINKS_API = "http://api.bongdahd.info/api/fixture/linkstream"
    
    /// Get user info url
    static let GET_USER_INFO_API = "http://api.bongdahd.info/api/customer/userinfo"
    
    /// Tracking IP url
    static let IP_TRACKING_URL = "https://www.trackip.net/ip?json"
    
    /// Default logo
    static let DEFAULT_TEAM_IMG = "tv_logo"
    
    // AES en/decript key
    static let AES_KEY = "1234567891234567"
    
    // Notification for loading user info
    static let USER_INFO_WAS_LOADED = "USER_INFO_WAS_LOADED"
}
