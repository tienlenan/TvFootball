//
//  TvEnumaration.swift
//  TvFootball
//
//  Created by admin on 8/12/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import UIKit

// MARK: - MatchType
enum MatchType: Int {
    case free = 0, paid = 1
}

// MARK: - TvUSerState
enum TvUSerState {
    /// Logged out from server
    case loggedOut
    
    /// Logged in facebook but could not load information
    case informationNotLoaded
    
    /// Information was loaded
    case informtionLoaded
}

// MARK: - HTTPResult
enum HTTPResult {
    case httpSuccess, httpErrorFromServer, httpConnectionError
}
