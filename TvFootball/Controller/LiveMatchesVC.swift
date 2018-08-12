//
//  LiveMatchesVC.swift
//  TvFootball
//
//  Created by admin on 8/8/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import UIKit
import VegaScrollFlowLayout
import CRRefresh
import SwiftyJSON
import Alamofire
import AlamofireImage

class LiveMatchesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, HTTPDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bannerImg: UIImageView!
    @IBOutlet weak var bannerView: UIView!
    
    var dataManager: DataManager!
    
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()

        // Data manager object
        self.dataManager = DataManager.shared
        
        // Register collection view cell
        self.collectionView.register(UINib(nibName: "MatchRow", bundle: nil), forCellWithReuseIdentifier: "matchRow")
        
        // Setup refresh view
        self.setupRefreshView()
        
        // Download banner image
        self.downloadBanner()
        
        self.dataManager.getLiveMatches(self)
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
                self?.dataManager.getLiveMatches(self)
            })
        }
    }
    
    // MARK: - IBACtion
    @IBAction func closeBanner(_ sender: UIButton) {
        self.bannerView.removeFromSuperview()
    }
    
    // MARK:-  Collection view data source and delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataManager.liveMatches.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MatchRow = collectionView.dequeueReusableCell(withReuseIdentifier: "matchRow", for: indexPath) as! MatchRow
        
        // Match object
        let match = dataManager.liveMatches[indexPath.row]
        
        // Set match title
        cell.teamsLabel.text = "\(match.teamHomeName)\n\(match.teamAwayName)"
        
        // Set date title
        cell.dateLabel.text = "\(match.startDate.fromIntToDateStr())"
        
        // Download images
        cell.homeTeamImg.image = UIImage(named: TvConstant.DEFAULT_TEAM_IMG)
        cell.awayTeamImg.image = UIImage(named: TvConstant.DEFAULT_TEAM_IMG)
        if let teamHomeImgUrl = match.teamHomeImgUrl {
            Alamofire.request(teamHomeImgUrl).responseImage { response in
                if let image = response.result.value {
                    cell.homeTeamImg.image = image
                }
            }
        }
        
        if let teamAwayImgUrl = match.teamAwayImgUrl {
            Alamofire.request(teamAwayImgUrl).responseImage { response in
                if let image = response.result.value {
                    cell.awayTeamImg.image = image
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Chosen match
        let match = self.dataManager.liveMatches[indexPath.row]
        
        // Get streaming links action
        let getStreamingLinks = {
            self.dataManager.mainTabBarVC.selectedIndex = 2
            self.dataManager.streamingMatch = self.dataManager.liveMatches[indexPath.row]
        }
        
        // Check free or not
        if match.type == MatchType.free.rawValue {
            // Get links immediately if free
            getStreamingLinks()
        } else {
            // This match was bought or not
            if self.dataManager.boughtMatches.contains(match.liveMatchId) {
                // Get links if match was bought
                getStreamingLinks()
            } else {
                // Show confirm message, asked user want to buy match or not
                // If user tap OK -> Get links
                // If user tap Cancel -> Dismiss popup
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 16, height: 80)
    }
    
    // MARK: - HTTPDelegate
    func didGetSuccessRespond(data: JSON?) {
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
