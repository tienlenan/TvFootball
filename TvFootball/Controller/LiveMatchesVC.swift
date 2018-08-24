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
import SwiftMessages

class LiveMatchesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, HTTPDelegate {
    
    // MARK: - IBOutlet
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bannerImg: UIImageView!
    @IBOutlet weak var bannerView: UIView!
    
    // MARK: - Variables
    
    /// Current working match
    var processingMatch: LiveMatch?
    
    // MARK: - Life cycle
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register collection view cell
        self.collectionView.register(UINib(nibName: "MatchRow", bundle: nil), forCellWithReuseIdentifier: "matchRow")
        
        // Setup refresh view
        self.setupRefreshView()
        
        // Download banner image
        self.downloadBanner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get matches
        if DataManager.shared.liveMatches.count == 0 {
            DataManager.shared.getLiveMatches(self)
        } else {
            self.collectionView.reloadData()
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
                DataManager.shared.getLiveMatches(self)
            })
        }
    }
    
    // MARK: - IBACtion
    @IBAction func closeBanner(_ sender: UIButton) {
        self.bannerView.removeFromSuperview()
    }
    
    // MARK:-  Collection view data source and delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataManager.shared.liveMatches.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MatchRow = collectionView.dequeueReusableCell(withReuseIdentifier: "matchRow", for: indexPath) as! MatchRow
        
        // Match object
        let match = DataManager.shared.liveMatches[indexPath.row]
        
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
        if DataManager.shared.userState == TvUSerState.loggedOut {
            // Show message notify app user that him/her didn't logged in
            AppUtility.showWarningMessage("You aren't logged in. Please login first!")
            return
        }
        
        if DataManager.shared.userState == TvUSerState.informationNotLoaded {
            // Show message notify app user that user information was not loaded
            AppUtility.showWarningMessage("Could not load your account information. Please try again later!")
            return
        }
        
        guard let _ = DataManager.shared.user else {
            return
        }
        
        // Chosen match
        let match = DataManager.shared.liveMatches[indexPath.row]
        
        // Get links in next tab
        DataManager.shared.mainTabBarVC.selectedIndex = 2
        DataManager.shared.streamingMatch = match
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 16, height: 80)
    }
    
    // MARK: - HTTPDelegate
    func didGetSuccessRespond(data: JSON?) {
        // Reload table after get live match successful
        self.collectionView.cr.endHeaderRefresh()
        self.collectionView.reloadData()
    }
    
    func didGetErrorFromServer(message: String) {
        self.collectionView.cr.endHeaderRefresh()
        AppUtility.showErrorMessage("Something is horribly wrong from server!")
    }
    
    func didGetConnectionError(message: String) {
        self.collectionView.cr.endHeaderRefresh()
        AppUtility.showErrorMessage("Please check your network connection!")
    }
}
