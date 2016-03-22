//
//  PrivacyPolicyViewController.swift
//  HotSpots
//
//  Created by mihad alzayat on 3/9/16.
//  Copyright © 2016 Mihad Alzayat. All rights reserved.
//

import UIKit

class PrivacyPolicyViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = NSURL (string: "http://hotspotsapp.us/privacy-policy.html");
        let requestObj = NSURLRequest(URL: url!);
        webView.loadRequest(requestObj);
       
    }


}
