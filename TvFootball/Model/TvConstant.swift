//
//  TvConstant.swift
//  TvFootball
//
//  Created by admin on 8/11/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import Foundation

class TvConstant: NSObject {
    static let shared: TvConstant = TvConstant()
    /// Banner image url
    var BANNER_IMAGE_URL = "https://i.imgur.com/QZ6j8Mg.png"
    
    /// Ads web url
    var ADS_URL = "https://www.fun88angels.com/vi/album"
    
    /// Ads web url
    var ADS2_URL = "http://www.skysports.com/football/news"
    
    /// For getting live matches url
    var GET_LIVE_MATCHES_API_URL = "http://api.bongdahd.info/api/fixture/list"
    
    /// For get links
    var GET_STREAM_LINKS_API = "http://api.bongdahd.info/api/fixture/linkstream"
    
    /// For get links
    var TRY_GET_STREAM_LINKS_API = "http://api.bongdahd.info/api/fixture/trylinkstream"
    
    /// Get user info url
    var GET_USER_INFO_API = "http://api.bongdahd.info/api/customer/userinfo"
    
    /// Tracking IP url
    var IP_TRACKING_URL = "https://www.trackip.net/ip?json"
    
    /// Default logo
    var DEFAULT_TEAM_IMG = "tv_logo"
    
    /// Not bought message
    var NOT_BOUGHT_MESSAGE = "NotBought"
    
    // AES en/decript key
    var AES_KEY = "1234567891234567"
    
    // Notification for loading user info
    var USER_INFO_WAS_LOADED = "USER_INFO_WAS_LOADED"
}
