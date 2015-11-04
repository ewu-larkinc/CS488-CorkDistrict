//
//  AlaskaWinePassViewController.swift
//  TheCorkDistrict
//
//  Created by Chris Larkin on 10/21/15.
//  Copyright © 2015 Madkatz. All rights reserved.
//

import Foundation
import UIKit

class AlaskaWinePassViewController: UIViewController, UIWebViewDelegate {
    
    @IBAction func refreshButtonSelected(sender: UIButton) {
        webView.reload()
    }
    
    @IBAction func stopButtonSelected(sender: UIButton) {
        webView.stopLoading()
    }
    
    @IBAction func forwardButtonSelected(sender: UIButton) {
        webView.goForward()
    }
    
    @IBAction func backButtonSelected(sender: UIButton) {
        webView.goBack()
    }
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.clipsToBounds = true
    }
    
    override func viewWillAppear(animated: Bool) {
        let data = CorkDistrictData.sharedInstance
        
        if let url = data.getCurrentURL() {
            let urlRequest = NSURLRequest(URL: url)
            webView.loadRequest(urlRequest)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        let data = CorkDistrictData.sharedInstance
        data.resetCurrentURL()
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        self.navigationController?.navigationItem.title = "Loading..."
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.navigationController?.navigationItem.title = "Alaska Wine Pass"
    }
    
    
}