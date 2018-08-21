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
import AVFoundation
import MobilePlayer

class StreamLinksVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, HTTPDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bannerImg: UIImageView!
    @IBOutlet weak var bannerView: UIView!
    
    var dataManager: DataManager! = DataManager.shared
    var urls: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup layout
        self.setupRefreshView()
        
        // Download banner
        self.downloadBanner()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let match = DataManager.shared.streamingMatch,
            let user = DataManager.shared.user {
            DataManager.shared.getStreamUrls(self, liveMatchId: match.liveMatchId, userId: user.uid)
        } else {
            self.collectionView.reloadData()
            AppUtility.showWarningMessage("You have to choose one match from \"Matches\" tab!")
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
        if let _ = DataManager.shared.streamingMatch {
            return urls.count + 1
        }
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let _ = DataManager.shared.streamingMatch {
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
                let leagueLabel = cell.viewWithTag(102) as? UILabel,
                let dateLabel = cell.viewWithTag(104) as? UILabel {
                
                homeTeamImgView.image = UIImage(named: TvConstant.DEFAULT_TEAM_IMG)
                awayTeamImgView.image = UIImage(named: TvConstant.DEFAULT_TEAM_IMG)
                if let teamHomeImgUrl = DataManager.shared.streamingMatch?.teamHomeImgUrl {
                    Alamofire.request(teamHomeImgUrl).responseImage { response in
                        if let image = response.result.value {
                            homeTeamImgView.image = image
                        }
                    }
                }
                
                if let teamAwayImgUrl = DataManager.shared.streamingMatch?.teamAwayImgUrl {
                    Alamofire.request(teamAwayImgUrl).responseImage { response in
                        if let image = response.result.value {
                            awayTeamImgView.image = image
                        }
                    }
                }
                
                if let streamingMatch = DataManager.shared.streamingMatch {
                    teamsLabel.text = "\(streamingMatch.teamHomeName)\n\(streamingMatch.teamAwayName)"
                    leagueLabel.text = "\(streamingMatch.tournamentName)"
                    dateLabel.text = "\(streamingMatch.startDate.fromIntToDateStr())"
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
            guard let match = DataManager.shared.streamingMatch else { return }
            let streamingURL = DataManager.shared.prepareStreamingURL(self.urls[indexPath.row - 1])
            
            // Check video url
            guard let videoURL = URL(string: streamingURL) else { return }
            
            // Enable audio session
            self.enableAudioSession()
            
            // Setup player
            let playerVC = MobilePlayerViewController(
                contentURL: videoURL,
                pauseOverlayViewController: MobilePlayerOverlayViewController())
            playerVC.title = "\(match.teamHomeName) - \(match.teamAwayName)"
            playerVC.activityItems = [videoURL]
            present(playerVC, animated: false, completion: nil)
            
            // Reset lock
            AppUtility.lockOrientation(.landscape, andRotateTo: .landscapeRight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat!
        if indexPath.row == 0 {
            height = 90
        } else {
            height = 50
        }
        return CGSize(width: collectionView.frame.width - 16, height: height)
    }
    
    // MARK: - HTTPDelegate
    
    func didGetSuccessRespond(data: JSON?) {
        guard let responseData = data else {
            return
        }
        self.urls = []
        let result = responseData["result"].stringValue
        let jsonLinksStr = DataManager.shared.decrypt(input: result, key: TvConstant.AES_KEY)
        let jsonLinks: JSON = JSON.init(parseJSON: jsonLinksStr)
        for item in jsonLinks {
            let link = item.1["Link"].stringValue
            self.urls.append(link)
        }
        self.collectionView.reloadData()
        
        if self.urls.count == 0 {
            AppUtility.showWarningMessage("Currently we aren't straming this match. Please come later!")
        }
    }
    
    func didGetErrorFromServer(message: String) {
        print("Error")
        AppUtility.showErrorMessage("Error when get streaming links!")
    }
    
    func didGetConnectionError(message: String) {
        print("Error")
        AppUtility.showErrorMessage("Please check your network connection!")
    }
}
