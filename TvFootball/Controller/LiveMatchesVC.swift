//
//  LiveMatchesVC.swift
//  TvFootball
//
//  Created by admin on 8/8/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import UIKit

class LiveMatchesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataManager: DataManager! = DataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataManager = DataManager.shared
        self.collectionView.register(UINib(nibName: "MatchRow", bundle: nil), forCellWithReuseIdentifier: "matchRow")
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.collectionView.frame.width - 10
        let height: CGFloat = 80
        return CGSize.init(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MatchRow = collectionView.dequeueReusableCell(withReuseIdentifier: "matchRow", for: indexPath) as! MatchRow
        let match = dataManager.liveMatches[indexPath.row]
        cell.teamsLabel.text = "\(match.teamHomeName)\n\(match.teamAwayName)"
        
        cell.homeTeamImg.image = UIImage(named: "tv-logo")
        cell.awayTeamImg.image = UIImage(named: "tv-logo")
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
