//
//  StreamingMatchVC.swift
//  TvFootball
//
//  Created by admin on 8/14/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import Foundation
import UIKit
import BMPlayer

class StreamingMatchVC: UIViewController {
    
    var dataManager: DataManager!
    var player: BMPlayer!
    
    @IBOutlet weak var view1: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataManager = DataManager.shared
    }
    
    override func viewDidAppear(_ animated: Bool) {
        player = BMPlayer()
        view1.addSubview(player)
        player.snp.makeConstraints { (make) in
            make.top.equalTo(self.view1).offset(-64)
            make.left.right.equalTo(self.view1)
            // Note here, the aspect ratio 16:9 priority is lower than 1000 on the line, because the 4S iPhone aspect ratio is not 16:9
            make.height.equalTo(player.snp.width).multipliedBy(9.0/16.0).priority(750)
        }
        // Back button event
        player.backBlock = { [unowned self] (isFullScreen) in
            if isFullScreen == true { return }
            let _ = self.navigationController?.popViewController(animated: true)
        }
        
        let asset = BMPlayerResource(url: URL(string: self.dataManager.temp)!,
                                     name: "ABC")
        player.setVideo(resource: asset)
    }
}
