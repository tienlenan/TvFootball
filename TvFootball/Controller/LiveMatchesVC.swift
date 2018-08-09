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

class LiveMatchesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, HTTPDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataManager: DataManager! = DataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Data manager object
        self.dataManager = DataManager.shared
        
        // Register collection view cell
        self.collectionView.register(UINib(nibName: "MatchRow", bundle: nil), forCellWithReuseIdentifier: "matchRow")
        
        // Setup layout
        let layout = VegaScrollFlowLayout()
        collectionView.collectionViewLayout = layout
        layout.minimumLineSpacing = 20
        layout.itemSize = CGSize(width: collectionView.frame.width - 16, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        /// animator: your customize animator, default is NormalHeaderAnimator
        self.collectionView.cr.addHeadRefresh(animator: SlackLoadingAnimator()) { [weak self] in
            /// Start refresh - Get live data
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                DataManager.shared.getLiveMatches(self)
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:-  Collection view data source and delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
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
        cell.dateLabel.text = "\(match.liveMatchId.fromIntToDateStr())"
        
        // Init default image for team's logo
        cell.homeTeamImg.image = UIImage(named: "tv-logo")
        cell.awayTeamImg.image = UIImage(named: "tv-logo")
        
        // Download images
        if let teamHomeImgUrl = match.teamHomeImgUrl {
            cell.homeTeamImg
                .downloadImageFrom(link: teamHomeImgUrl, contentMode: UIViewContentMode.scaleAspectFit)
        }
        
        if let teamAwayImgUrl = match.teamAwayImgUrl {
            cell.awayTeamImg.downloadImageFrom(link: teamAwayImgUrl, contentMode: UIViewContentMode.scaleAspectFit)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.dataManager.mainTabBarVC.selectedIndex = 2
        DataManager.shared.liveMatchId = self.dataManager.liveMatches[indexPath.row].liveMatchId
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
