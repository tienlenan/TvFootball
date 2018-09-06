//
//  AppUtility.swift
//  TvFootball
//
//  Created by admin on 8/11/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import UIKit
import SwiftMessages

struct AppUtility {
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
    static func showErrorMessage(_ message: String) {
        // Show the message.
        SwiftMessages.show {
            // Instantiate a message view from the provided card view layout. SwiftMessages searches for nib
            // files in the main bundle first, so you can easily copy them into your project and make changes.
            let view = MessageView.viewFromNib(layout: .cardView)
            
            // Theme message elements with the warning style.
            view.configureTheme(.error, iconStyle: .light)
            
            // Add a drop shadow.
            view.configureDropShadow()
            
            // Hide button
            view.button?.isHidden = true
            
            // Set message title, body, and icon. Here, we're overriding the default warning
            // image with an emoji character.
            view.configureContent(title: "Lỗi", body: message)
            
            return view
        }
    }
    
    static func showSuccessMessage(_ message: String) {
        // Show the message.
        SwiftMessages.show {
            // Instantiate a message view from the provided card view layout. SwiftMessages searches for nib
            // files in the main bundle first, so you can easily copy them into your project and make changes.
            let view = MessageView.viewFromNib(layout: .cardView)
            
            // Theme message elements with the warning style.
            view.configureTheme(.success, iconStyle: .light)
            
            // Add a drop shadow.
            view.configureDropShadow()
            
            // Hide button
            view.button?.isHidden = true
            
            // Set message title, body, and icon. Here, we're overriding the default warning
            // image with an emoji character.
            view.configureContent(title: "Thành công", body: message)
            
            return view
        }
    }
    
    static func showWarningMessage(_ message: String) {
        // Show the message.
        SwiftMessages.show {
            // Instantiate a message view from the provided card view layout. SwiftMessages searches for nib
            // files in the main bundle first, so you can easily copy them into your project and make changes.
            let view = MessageView.viewFromNib(layout: .cardView)
            
            // Theme message elements with the warning style.
            view.configureTheme(.warning, iconStyle: .light)
            
            // Add a drop shadow.
            view.configureDropShadow()
            
            // Hide button
            view.button?.isHidden = true
            
            // Set message title, body, and icon. Here, we're overriding the default warning
            // image with an emoji character.
            view.configureContent(title: "Cảnh báo", body: message)
            
            return view
        }
    }
}
