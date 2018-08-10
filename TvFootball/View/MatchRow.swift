//
//  MatchRow.swift
//  TvFootball
//
//  Created by admin on 8/8/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import UIKit
import FontAwesome_swift

class MatchRow: UICollectionViewCell {

    @IBOutlet weak var teamsLabel: UILabel!
    @IBOutlet weak var homeTeamImg: UIImageView!
    @IBOutlet weak var awayTeamImg: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    lazy var lazyImage: LazyImage = LazyImage()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.white.cgColor
        self.teamsLabel.font = UIFont.fontAwesome(ofSize: 19, style: .regular)
        self.dateLabel.font = UIFont.fontAwesome(ofSize: 16, style: .regular)
    }
}
