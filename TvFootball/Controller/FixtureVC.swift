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
    @IBOutlet weak var topBannerImg: UIImageView!
    @IBOutlet weak var topBannerView: UIView!
    
    @IBOutlet weak var bottomBannerImg: UIImageView!
    @IBOutlet weak var bottomBannerView: UIView!
    
    // MARK: - Variables
    var webView : WKWebView!
    var isLoaded = false

    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load webview
        self.loadTvWebView()
        
        // Action for banners
        self.addActionForBanners()
        
        // Download banner image
        self.downloadBanner()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isLoaded {
            let url = URL(string: TvConstant.ADS_URL)
            let request = URLRequest(url: url!)
            webView.load(request)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.isLoaded = false
    }
    
    private func addActionForBanners() {
        let tapTopBanner = UITapGestureRecognizer(target: self, action: #selector(self.tappedBanner))
        let tapBottomBanner = UITapGestureRecognizer(target: self, action: #selector(self.tappedBanner))
        topBannerImg.isUserInteractionEnabled = true
        topBannerImg.addGestureRecognizer(tapTopBanner)
        bottomBannerImg.isUserInteractionEnabled = true
        bottomBannerImg.addGestureRecognizer(tapBottomBanner)
    }
    
    /// Download banner, show banner view when completed download banner image
    private func downloadBanner() {
        Alamofire.request(TvConstant.TOP_BANNER_IMAGE_URL).responseImage { response in
            if let image = response.result.value {
                self.topBannerImg.image = image
                self.topBannerView.isHidden = false
            }
        }
        
        Alamofire.request(TvConstant.BOTTOM_BANNER_IMAGE_URL).responseImage { response in
            if let image = response.result.value {
                self.bottomBannerImg.image = image
                self.bottomBannerView.isHidden = false
            }
        }
    }
    
    @objc func tappedBanner() {
        AppUtility.openURL(TvConstant.BANNER_ACTION_URL)
    }
    
    // MARK: - IBACtion
    @IBAction func closeTopBanner(_ sender: UIButton) {
        self.topBannerView.removeFromSuperview()
    }
    
    @IBAction func closeBottomBanner(_ sender: UIButton) {
        self.bottomBannerView.removeFromSuperview()
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
        self.isLoaded = true
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
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated  {
            if let url = navigationAction.request.url,
                let host = url.host, !host.hasPrefix(TvConstant.LINKED_URL),
                UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                print(url)
                print("Redirected to browser. No need to open it locally")
                decisionHandler(.cancel)
            } else {
                print("Open it locally")
                decisionHandler(.allow)
            }
        } else {
            print("not a user click")
            decisionHandler(.allow)
        }
    }
    
}
