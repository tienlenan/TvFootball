//
//  FixtureVC.swift
//  TvFootball
//
//  Created by Le Tien An on 8/8/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import AlamofireImage

class FixtureVC: UIViewController, WKNavigationDelegate {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tvWebView: UIView!
    @IBOutlet weak var bannerImg: UIImageView!
    @IBOutlet weak var bannerView: UIView!
    
    // MARK: - Variables
    var webView : WKWebView!

    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load webview
        self.loadTvWebView()
        
        // Download banner image
        self.downloadBanner()
    }
    
    /// Download banner, show banner view when completed download banner image
    private func downloadBanner() {
        Alamofire.request(TvConstant.BANNER_IMAGE_URL).responseImage { response in
            if let image = response.result.value {
                self.bannerImg.image = image
                self.bannerView.isHidden = false
            }
        }
    }
    
    // MARK: - IBACtion
    @IBAction func closeBanner(_ sender: UIButton) {
        self.bannerView.removeFromSuperview()
    }
    
    // MARK: - Private function
    
    /// Load webview content
    private func loadTvWebView() {
        let url = URL(string: TvConstant.ADS_URL)
        let request = URLRequest(url: url!)
        webView = WKWebView(frame: tvWebView.frame)
        webView.navigationDelegate = self
        webView.load(request)
        tvWebView.addSubview(webView)
        tvWebView.sendSubview(toBack: webView)
    }
    
    // MARK: - WKWebViewNavigation
    
    /// Did fail provisional navigation
    ///
    /// - Parameters:
    ///   - webView: vew view
    ///   - navigaion: navigation
    ///   - error: error
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // Debug
        print(error.localizedDescription)
    }
    
    /// Did start provisional navigation
    ///
    /// - Parameters:
    ///   - webView: web view
    ///   - navigation: navigation
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Web View started...")
    }
    
    /// Did finish navigation
    ///
    /// - Parameters:
    ///   - webView: web view
    ///   - navigation: navigation
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Web View finished...")
    }
    
    /// Decide policy for navigation response
    ///
    /// - Parameters:
    ///   - webView: web view
    ///   - navigationResponse: navigation response
    ///   - decisionHandler: decision handler
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: (@escaping (WKNavigationResponsePolicy) -> Void)){
        decisionHandler(.allow)
        // Write in sub-class
    }
    
}
