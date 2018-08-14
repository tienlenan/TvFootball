//
//  TvFacebookUSer.swift
//  TvFootball
//
//  Created by Le Tien An on 8/14/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import Foundation

struct TvFacebookUSer {
    var fid: String
    var email: String
    var name: String
    
    init(fid: String, email: String, name: String) {
        self.fid = fid
        self.email = email
        self.name = name
    }
}
