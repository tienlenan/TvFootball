//
//  ExtensionHelper.swift
//  TvFootball
//
//  Created by admin on 8/9/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import UIKit
import CryptoSwift

extension String {
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}

extension Int {
    func fromIntToDateStr() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm dd-MM-YYYY"
        
        return formatter.string(from: date)
    }
}
