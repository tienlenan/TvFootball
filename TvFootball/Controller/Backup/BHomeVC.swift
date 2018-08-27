//
//  BHomeVC.swift
//  TvFootball
//
//  Created by Le Tien An on 8/27/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import UIKit

class BHomeVC: UIViewController {
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Lock portrait
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    @IBAction func tapNewsButton(_ sender: Any) {
    }
    @IBAction func tapMatchesButton(_ sender: Any) {
    }
}
