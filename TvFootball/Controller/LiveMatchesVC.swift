//
//  LiveMatchesVC.swift
//  TvFootball
//
//  Created by admin on 8/8/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import UIKit
import VegaScrollFlowLayout

class LiveMatchesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataManager: DataManager! = DataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataManager = DataManager.shared
        self.collectionView.register(UINib(nibName: "MatchRow", bundle: nil), forCellWithReuseIdentifier: "matchRow")
        
        let layout = VegaScrollFlowLayout()
        collectionView.collectionViewLayout = layout
        layout.minimumLineSpacing = 20
        layout.itemSize = CGSize(width: collectionView.frame.width - 16, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
}
