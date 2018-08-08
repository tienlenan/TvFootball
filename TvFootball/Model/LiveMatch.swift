//
//  LiveMatch.swift
//  TvFootball
//
//  Created by Le Tien An on 8/8/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import SwiftyJSON

struct LiveMatch {
    var liveMatchId: Int
    var slug: String
    var teamHomeName: String
    var teamHomeImgUrl: String?
    var teamAwayName: String
    var teamAwayImgUrl: String?
    var startDate: String
    var tournamentName: String
    var liveMatchTypeId: Int
    var type: Int
    
    init(jsonData: JSON) {
        self.liveMatchId        = jsonData["LiveMatchId"].intValue
        self.slug               = jsonData["LiveMatchId"].stringValue
        self.teamHomeName       = jsonData["LiveMatchId"].stringValue
        self.teamHomeImgUrl     = jsonData["LiveMatchId"].string
        self.teamAwayName       = jsonData["LiveMatchId"].stringValue
        self.teamAwayImgUrl     = jsonData["LiveMatchId"].string
        self.startDate          = jsonData["LiveMatchId"].stringValue
        self.tournamentName     = jsonData["LiveMatchId"].stringValue
        self.liveMatchTypeId    = jsonData["LiveMatchId"].intValue
        self.type               = jsonData["LiveMatchId"].intValue
    }
}

