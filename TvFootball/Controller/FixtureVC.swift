//
//  FixtureVC.swift
//  TvFootball
//
//  Created by Le Tien An on 8/8/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import UIKit
import WebKit

class FixtureVC: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var tvWebView: UIView!
    
    let adsURL = "https:www.fun88angels.com/vi/album"
    var webView : WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.loadTvWebView()
        
        let bannerView = BannerView()
        let widthOfParent = self.tvWebView.bounds.size.width
        let heightOfParent = self.tvWebView.bounds.size.height
        let rect = CGRect(x: 0, y: heightOfParent - 50, width: widthOfParent, height: 50)
        let customView = UIView(frame: rect)
        customView.addSubview(bannerView)
        self.tvWebView.addSubview(customView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadTvWebView() {
        let url = URL(string: adsURL)
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
