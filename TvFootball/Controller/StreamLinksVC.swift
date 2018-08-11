//
//  StreamLinksVC.swift
//  TvFootball
//
//  Created by admin on 8/9/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import UIKit
import VegaScrollFlowLayout
import CRRefresh
import SwiftyJSON
import Alamofire
import AlamofireImage
import MobilePlayer
import AVFoundation

class StreamLinksVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, HTTPDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bannerImg: UIImageView!
    @IBOutlet weak var bannerView: UIView!
    
    var dataManager: DataManager! = DataManager.shared
    var urls: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Data manager object
        self.dataManager = DataManager.shared
        
        // Setup layout
        let layout = VegaScrollFlowLayout()
        collectionView.collectionViewLayout = layout
        layout.minimumLineSpacing = 20
        layout.itemSize = CGSize(width: collectionView.frame.width - 16, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        self.bannerImg.downloadImageFrom(link: BANNER_IMAGE_URL, contentMode: .scaleToFill)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let match = self.dataManager.streamingMatch {
            self.dataManager.getStreamUrls(self, liveMatchId: match.liveMatchId)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /// Enable audio even if app is on silent/ringer mode
    private func enableAudioSession() {
        do {
            try AVAudioSession
                .sharedInstance()
                .setCategory(AVAudioSessionCategoryPlayback)
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch _ as NSError {
                print("Error when enable audio session")
            }
        } catch _ as NSError {
            print("Error when set category blayback for audio session")
        }
    }
    
    @IBAction func closeBanner(_ sender: UIButton) {
        self.bannerView.removeFromSuperview()
    }
    
    // MARK:-  Collection view data source and delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let _ = self.dataManager.streamingMatch {
            return urls.count + 1
        }
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell!
        
        if indexPath.row == 0 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "matchRow", for: indexPath)
            if let homeTeamImgView = cell.viewWithTag(100) as? UIImageView,
                let awayTeamImgView = cell.viewWithTag(102) as? UIImageView,
                let teamsLabel = cell.viewWithTag(101) as? UILabel {
                
                homeTeamImgView.image = UIImage(named: DEFAULT_TEAM_IMG)
                awayTeamImgView.image = UIImage(named: DEFAULT_TEAM_IMG)
                if let teamHomeImgUrl = self.dataManager.streamingMatch?.teamHomeImgUrl {
                    Alamofire.request(teamHomeImgUrl).responseImage { response in
                        if let image = response.result.value {
                            homeTeamImgView.image = image
                        }
                    }
                }
                
                if let teamAwayImgUrl = self.dataManager.streamingMatch?.teamAwayImgUrl {
                    Alamofire.request(teamAwayImgUrl).responseImage { response in
                        if let image = response.result.value {
                            awayTeamImgView.image = image
                        }
                    }
                }
                
                if let streamingMatch = self.dataManager.streamingMatch {
                    teamsLabel.text = "\(streamingMatch.teamHomeName)\n\(streamingMatch.teamAwayName)"
                    teamsLabel.font = UIFont.fontAwesome(ofSize: 19, style: .regular)
                }
            }
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "linkRow", for: indexPath)
            if let linkLabel = cell.viewWithTag(100) as? UILabel {
                linkLabel.text = "Link \(indexPath.row)"
                linkLabel.font = UIFont.fontAwesome(ofSize: 19, style: .regular)
            }
        }
        
        // Set border
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.white.cgColor
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row > 0 {
            // Show streaming screen
            guard let match = self.dataManager.streamingMatch else { return }
            guard let videoURL = URL(string: self.urls[indexPath.row - 1]) else { return }
            let playerVC = MobilePlayerViewController(
                contentURL: videoURL,
                config: MobilePlayerConfig())
            playerVC.title = "\(match.teamHomeName) - \(match.teamAwayName)"
            playerVC.activityItems = [videoURL]
            present(playerVC, animated: false, completion: nil)
        }
    }
    
    // MARK: - HTTPDelegate
    
    func didGetSuccessRespond(data: JSON?) {
        self.urls = ["http://sample.vodobox.net/skate_phantom_flex_4k/skate_phantom_flex_4k.m3u8",
                     "http://sample.vodobox.net/skate_phantom_flex_4k/skate_phantom_flex_4k.m3u8"]
        self.collectionView.cr.endHeaderRefresh()
        self.collectionView.reloadData()
    }
    
    func didGetErrorFromServer(message: String) {
        print("Error")
        self.collectionView.cr.endHeaderRefresh()
    }
    
    func didGetConnectionError(message: String) {
        print("Error")
        self.collectionView.cr.endHeaderRefresh()
    }
}
