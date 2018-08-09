//
//  MatchRow.swift
//  TvFootball
//
//  Created by admin on 8/8/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import UIKit

class MatchRow: UICollectionViewCell {

    @IBOutlet weak var teamsLabel: UILabel!
    @IBOutlet weak var homeTeamImg: UIImageView!
    @IBOutlet weak var awayTeamImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.white.cgColor
        self.bringSubview(toFront: teamsLabel)
        self.bringSubview(toFront: homeTeamImg)
        self.bringSubview(toFront: awayTeamImg)
    }
}
