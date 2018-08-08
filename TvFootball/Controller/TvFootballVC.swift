//
//  TvFootballVC.swift
//  TvFootball
//
//  Created by Le Tien An on 8/8/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import UIKit

class TvFootballVC: UITabBarController {
    
    // MARK: Life cycle
    override func viewDidLoad() {
        DataManager.shared.getLiveMatches()
    }
}
