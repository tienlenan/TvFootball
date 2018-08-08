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
        self.slug               = jsonData["Slug"].stringValue
        self.teamHomeName       = jsonData["TeamHome_name"].stringValue
        self.teamHomeImgUrl     = jsonData["TeamHome_image"].string
        self.teamAwayName       = jsonData["TeamAway_name"].stringValue
        self.teamAwayImgUrl     = jsonData["TeamAway_image"].string
        self.startDate          = jsonData["StartDate"].stringValue
        self.tournamentName     = jsonData["Tournament_name"].stringValue
        self.liveMatchTypeId    = jsonData["LiveMatchTypeId"].intValue
        self.type               = jsonData["Type"].intValue
    }
}

