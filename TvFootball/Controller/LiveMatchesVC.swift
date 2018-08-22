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
    /// Current action is none
    lazy var tvAction: TvAction = TvAction.none
    
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
        
        // Get matches if action is none
        if self.tvAction == TvAction.none {
            if DataManager.shared.liveMatches.count == 0 {
                DataManager.shared.getLiveMatches(self)
                self.tvAction = TvAction.getLiveMatches
            } else {
                self.collectionView.reloadData()
            }
        }
    }
    
    /// On tapped this view controller
    public func onTapped() {
        // Get matches if action is none
        if self.tvAction == TvAction.none {
            DataManager.shared.getLiveMatches(self)
            self.tvAction = TvAction.getLiveMatches
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
                self?.tvAction = TvAction.getLiveMatches
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
        
        guard let user = DataManager.shared.user else {
            return
        }
        
        // Chosen match
        let match = DataManager.shared.liveMatches[indexPath.row]
        
        // Check free or not
        if match.type == MatchType.free.rawValue {
            // Get links immediately if free
            DataManager.shared.mainTabBarVC.selectedIndex = 2
            DataManager.shared.streamingMatch = match
        } else {
            // Set tapped match
            self.processingMatch = match
            
            // Send get streaming links to check this match was bought or not
            DataManager.shared.getStreamUrls(self, liveMatchId: match.liveMatchId, userId: user.uid)
            
            // Set current action
            self.tvAction = TvAction.getStreamingLinks
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
        if self.tvAction == TvAction.getLiveMatches {
            // Reload table after get live match successful
            self.collectionView.cr.endHeaderRefresh()
            self.collectionView.reloadData()
            self.tvAction = TvAction.none
            
        } else if self.tvAction == TvAction.getStreamingLinks {
            // Show error message if don't have data from server
            guard let responseData = data else {
                self.tvAction = TvAction.none
                AppUtility.showErrorMessage("Something is horribly wrong from server!")
                return
            }
            
            guard let user = DataManager.shared.user else {
                self.tvAction = TvAction.none
                AppUtility.showErrorMessage("Something is horribly wrong!")
                return
            }
            
            // Check data: If didn't bought
            if responseData["message"].stringValue == TvConstant.NOT_BOUGHT_MESSAGE {
                if user.coins > 3000 {
                    guard let match = self.processingMatch else {
                        self.tvAction = TvAction.none
                        AppUtility.showErrorMessage("Something is horribly wrong!")
                        return
                    }
                    
                    // Show confirm message, asked user want to buy match or not
                    // If user tap OK -> Get links
                    // If user tap Cancel -> Dismiss popup
                    let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
                    messageView.configureBackgroundView(width: 290)
                    messageView.configureContent(title: "TvFootball", body: "Press 'Yes' to buy this match. If you don't want, please try swiping to dismiss this message.", iconImage: nil, iconText: "🦄", buttonImage: nil, buttonTitle: "Yes") { _ in
                        self.tvAction = TvAction.buyStreamingMatch
                        DataManager.shared.buyStreamingMatch(self, liveMatchId: match.liveMatchId, userId: user.uid)
                        SwiftMessages.hide()
                    }
                    messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
                    messageView.backgroundView.layer.cornerRadius = 10
                    var config = SwiftMessages.defaultConfig
                    config.presentationStyle = .center
                    config.duration = .forever
                    config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
                    config.presentationContext  = .window(windowLevel: UIWindowLevelStatusBar)
                    SwiftMessages.show(config: config, view: messageView)
                } else {
                    self.tvAction = TvAction.none
                    AppUtility.showErrorMessage("You don't have enought coins to buy this match!")
                }
                
            } else {
                self.tvAction = TvAction.none
                DataManager.shared.mainTabBarVC.selectedIndex = 2
                DataManager.shared.streamingMatch = self.processingMatch
            }
            
        } else if self.tvAction == TvAction.buyStreamingMatch {
            // Buy match successful
            AppUtility.showSuccessMessage("You've already bought this match, enjoy it!")
            
            // Go to streaming tab
            self.tvAction = TvAction.none
            DataManager.shared.mainTabBarVC.selectedIndex = 2
            DataManager.shared.streamingMatch = self.processingMatch
        }
    }
    
    func didGetErrorFromServer(message: String) {
        self.collectionView.cr.endHeaderRefresh()
        self.tvAction = TvAction.none
        AppUtility.showErrorMessage("Something is horribly wrong from server!")
    }
    
    func didGetConnectionError(message: String) {
        self.collectionView.cr.endHeaderRefresh()
        self.tvAction = TvAction.none
        AppUtility.showErrorMessage("Please check your network connection!")
    }
}
