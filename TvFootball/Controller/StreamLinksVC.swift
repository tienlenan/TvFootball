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
        self.setupRefreshView()
        
        // Download banner
        self.downloadBanner()
        
        // Enable audio session
        self.enableAudioSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let match = self.dataManager.streamingMatch,
            let user = self.dataManager.user {
            self.dataManager.getStreamUrls(self, liveMatchId: match.liveMatchId, userId: user.uid)
        }
    }
    
    /// Download banner, show banner view when completed download banner image
    private func downloadBanner() {
        Alamofire.request(TvConstant.BANNER_IMAGE_URL).responseImage { response in
            if let image = response.result.value {
                self.bannerImg.image = image
                self.bannerView.isHidden = false
            }
        }
    }
    
    /// Setting up refresh view, load data again when user scroll down list
    /// And setting up scroll view
    private func setupRefreshView() {
        // When user scroll view app will get data once time again
        let layout = VegaScrollFlowLayout()
        collectionView.collectionViewLayout = layout
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 0)
        self.collectionView.cr.addHeadRefresh(animator: SlackLoadingAnimator()) { [weak self] in
            /// Start refresh - Get live data
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                if let match = self?.dataManager.streamingMatch,
                    let user = self?.dataManager.user {
                    self?.dataManager.getStreamUrls(self, liveMatchId: match.liveMatchId, userId: user.uid)
                }
            })
        }
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
        if let _ = self.dataManager.streamingMatch {
            return 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell!
        
        if indexPath.row == 0 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "matchRow", for: indexPath)
            if let homeTeamImgView = cell.viewWithTag(100) as? UIImageView,
                let awayTeamImgView = cell.viewWithTag(103) as? UIImageView,
                let teamsLabel = cell.viewWithTag(101) as? UILabel,
                let leagueLabel = cell.viewWithTag(102) as? UILabel{
                
                homeTeamImgView.image = UIImage(named: TvConstant.DEFAULT_TEAM_IMG)
                awayTeamImgView.image = UIImage(named: TvConstant.DEFAULT_TEAM_IMG)
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
                    
                    leagueLabel.text = "\(streamingMatch.tournamentName)"
                }
            }
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "linkRow", for: indexPath)
            if let linkLabel = cell.viewWithTag(100) as? UILabel {
                linkLabel.text = "Link \(indexPath.row)"
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
                pauseOverlayViewController: MobilePlayerOverlayViewController())
            playerVC.title = "\(match.teamHomeName) - \(match.teamAwayName)"
            playerVC.activityItems = [videoURL]
            present(playerVC, animated: false, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 16, height: 80)
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
