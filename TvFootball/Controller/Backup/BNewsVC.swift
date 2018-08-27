//
//  BNewsVC.swift
//  TvFootball
//
//  Created by admin on 8/27/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import UIKit
import WebKit

class BNewsVC: UIViewController, WKNavigationDelegate {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tvWebView: UIView!
    
    // MARK: - Variables
    var webView : WKWebView!
    var idLoaded = false
    
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load webview
        self.loadTvWebView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !idLoaded {
            let url = URL(string: TvConstant.shared.ADS2_URL)
            let request = URLRequest(url: url!)
            webView.load(request)
        }
    }
    
    // MARK: - Private function
    
    /// Load webview content
    private func loadTvWebView() {
        let url = URL(string: TvConstant.shared.ADS_URL)
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
        self.idLoaded = true
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
