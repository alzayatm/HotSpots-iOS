//
//  ContactUsViewcontroller.swift
//  HotSpots
//
//  Created by mihad alzayat on 1/7/16.
//  Copyright © 2016 Mihad Alzayat. All rights reserved.
//

import UIKit

class ContactUsViewcontroller: UIViewController, UITextViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailAddressTextField: CustomUITextField!
    @IBOutlet weak var issueTextField: CustomUITextField!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        self.issueTextFieldConfig()
        self.emailAddressTextFieldConfig()
        self.textViewConfig()
    }

    func issueTextFieldConfig() {
        
        self.issueTextField.layer.borderColor = UIColor.orangeColor().CGColor
        self.issueTextField.layer.borderWidth = 0.9
        self.issueTextField.layer.cornerRadius = 5
        self.issueTextField.placeholder = "Issue"
    }
    
    func emailAddressTextFieldConfig() {
        
        self.emailAddressTextField.layer.borderColor = UIColor.orangeColor().CGColor
        self.emailAddressTextField.layer.borderWidth = 0.9
        self.emailAddressTextField.layer.cornerRadius = 5
        self.emailAddressTextField.placeholder = "Your email address"
        self.emailAddressTextField.keyboardType = .EmailAddress
    }
    
    func textViewConfig() {
        
        self.textView.layer.borderColor = UIColor.orangeColor().CGColor
        self.textView.layer.borderWidth = 0.9
        self.textView.layer.cornerRadius = 5
        self.textView.text = "Tell us about it..."
        self.textView.textColor = UIColor.lightGrayColor()
        let fontName = self.emailAddressTextField.font?.fontName
        self.textView.font = UIFont(name: fontName! ,size: 15)
        self.textView.delegate = self
        
    }
  
    @IBAction func sendMessage(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }

    func textViewDidEndEditing(textView: UITextView) {
        
        if textView.text.isEmpty {
            textView.text = "Tell us about it..."
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
   

}
