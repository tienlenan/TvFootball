//
//  HTTPDelegate.swift
//  TvFootball
//
//  Created by Le Tien An on 8/8/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import SwiftyJSON

protocol HTTPDelegate: class {
    func didGetSuccessRespond(data: JSON?)
    func didGetErrorFromServer(message: String)
    func didGetConnectionError(message: String)
}
