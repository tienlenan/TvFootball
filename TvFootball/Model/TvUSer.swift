//
//  TvUSer.swift
//  TvFootball
//
//  Created by admin on 8/12/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import Foundation

struct TvUser {
    var uid: Int
    var coins: Int
    
    init(uid: Int, coins: Int) {
        self.uid = uid
        self.coins = coins
    }
    
    mutating func updateAfterBoughtMatch() {
        self.coins = self.coins - 3000
    }
}
