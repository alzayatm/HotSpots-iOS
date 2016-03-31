//
//  HowItWorksViewController.swift
//  HotSpots
//
//  Created by mihad alzayat on 3/9/16.
//  Copyright © 2016 Mihad Alzayat. All rights reserved.
//

import UIKit

class HowItWorksViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.backgroundColor = UIColor.clearColor()
        self.automaticallyAdjustsScrollViewInsets = false
    
        let url = NSURL (string: "http://hotspotsapp.us/how-it-works.html");
        let requestObj = NSURLRequest(URL: url!);
        webView.loadRequest(requestObj);
        
    }
}
