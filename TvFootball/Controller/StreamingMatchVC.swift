//
//  StreamingMatchVC.swift
//  TvFootball
//
//  Created by admin on 8/14/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import Foundation
import UIKit

class StreamingMatchVC: UIViewController, VLCMediaPlayerDelegate {
    
    var dataManager: DataManager!
    
    let player: VLCMediaPlayer = {
        let p = VLCMediaPlayer()
        return p
    }()
    @IBOutlet weak var playerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataManager = DataManager.shared
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        self.navigationController?.hidesBarsOnSwipe = true
        
        VLCLibrary.shared().setHumanReadableName("iOS Player", withHTTPUserAgent: "ExoMedia")
        
        setupPlayer()
    }
    
    func setupPlayer() {
        playerView.backgroundColor = UIColor.black
        
        let streamURL = URL(string: self.dataManager.temp)!
        
        let media = VLCMedia(url: streamURL)
        
        player.media = media
        player.delegate = self
        player.drawable = playerView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.tintColor = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.hidesBarsOnSwipe = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        player.play()
    }
    
    
}
