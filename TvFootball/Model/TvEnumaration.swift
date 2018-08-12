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
