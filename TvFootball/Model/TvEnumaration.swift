//
//  TvEnumaration.swift
//  TvFootball
//
//  Created by admin on 8/12/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import UIKit

enum TvAction {
    case none
    case getLiveMatches
    case getStreamingLinks
    case buyStreamingMatch
}

enum MatchType: Int {
    case free = 0, paid = 1
}

enum TvUSerState {
    /// Logged out from server
    case loggedOut
    
    /// Logged in facebook but could not load information
    case informationNotLoaded
    
    /// Information was loaded
    case informtionLoaded
}
