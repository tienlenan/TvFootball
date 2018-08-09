//
//  BannerView.swift
//  TvFootball
//
//  Created by Le Tien An on 8/9/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import UIKit

class BannerView: UIView {
    
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Setup view from .xib file
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Setup view from .xib file
        xibSetup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.bannerImage.downloadImageFrom(link: BANNER_IMAGE_URL, contentMode: .scaleAspectFit)
    }
    
}

private extension BannerView {
    
    func xibSetup() {
        backgroundColor = UIColor.clear
        let view = loadNib()
        // use bounds not frame or it'll be offset
        view.frame = bounds
        view.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[childView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: ["childView": view]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[childView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: ["childView": view]))
        
        // Adding custom subview on top of our view
        addSubview(view)
    }
}

extension UIView {
    /** Loads instance from nib with the same name. */
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
}
