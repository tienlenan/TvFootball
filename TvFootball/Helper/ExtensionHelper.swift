//
//  ExtensionHelper.swift
//  TvFootball
//
//  Created by admin on 8/9/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import UIKit

extension UIImageView {
    func downloadImageFrom(link: String, contentMode: UIViewContentMode) {
        URLSession.shared.dataTask(with: NSURL(string:link)! as URL, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                self.contentMode =  contentMode
                if let data = data { self.image = UIImage(data: data) }
            }
        }).resume()
    }
}
