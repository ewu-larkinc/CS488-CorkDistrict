//
//  EmbeddedWebViewController.swift
//  TheCorkDistrict
//
//  Created by Chris Larkin on 10/23/15.
//  Copyright © 2015 Madkatz. All rights reserved.
//

import Foundation
import UIKit


class EmbeddedWebViewController: UIViewController {
    
    
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
    @IBOutlet weak var loadingLabel: UILabel!
    
    override func viewDidLoad() {
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.clipsToBounds = true
        self.title = "Cork District Web"
    }
    
    override func viewWillAppear(animated: Bool) {
        let data = CorkDistrictData.sharedInstance
        
        if let url = data.getCurrentURL() {
            print("loading url \(url)")
            let urlRequest = NSURLRequest(URL: url)
            webView.loadRequest(urlRequest)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        let data = CorkDistrictData.sharedInstance
        data.resetCurrentURL()
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        
        UIView.animateKeyframesWithDuration(1.0, delay: 0.0, options: [.Autoreverse, .Repeat, .AllowUserInteraction], animations: {
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1/2, animations: {
                self.loadingLabel.alpha = 0.2
            })
            
            UIView.addKeyframeWithRelativeStartTime(1/2, relativeDuration: 1/2, animations: {
                self.loadingLabel.alpha = 1.0
            })
            
        }, completion: nil)
        
        
        //Attempting a trailing ellipsis animation...
        /*var ctr=0
        while ctr < 4 {
        
            var text = loadingLabel.text!
            loadingLabel.text = text + " ."
            text = loadingLabel.text!
            ctr++
            loadingLabel.setNeedsDisplay()
            NSThread.sleepForTimeInterval(NSTimeInterval(0.25))
        }*/
    
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        loadingLabel.hidden = true
    }
}