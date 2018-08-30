//
//  ContactVC.swift
//  TvFootball
//
//  Created by admin on 8/30/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import UIKit

class ContactVC: UIViewController {

    @IBOutlet weak var alertLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: self, action: #selector(ContactVC.tapAlertLabel))
        alertLabel.isUserInteractionEnabled = true
        alertLabel.addGestureRecognizer(tap)
    }
    
    @objc
    func tapAlertLabel(sender:UITapGestureRecognizer) {
        guard let url = URL(string: TvConstant.FOREVER_SERVICE_URL) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
