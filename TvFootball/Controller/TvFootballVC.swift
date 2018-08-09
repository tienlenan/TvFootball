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
        // Set title image
        let image : UIImage = #imageLiteral(resourceName: "tv_logo")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        self.navigationItem.titleView = imageView
        
        // Get live data
        DataManager.shared.mainTabBarVC = self
        DataManager.shared.getLiveMatches(nil)
        
    }
}
