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
    
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title image
        let image : UIImage = #imageLiteral(resourceName: "tv_logo")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        self.navigationItem.titleView = imageView
        
        // Get live data
        DataManager.shared.mainTabBarVC = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Lock portrait
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Reset lock
        AppUtility.lockOrientation(.all, andRotateTo: .landscapeRight)
    }
}
