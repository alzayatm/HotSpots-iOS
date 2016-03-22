//
//  TutorialViewController.swift
//  HotSpots
//
//  Created by mihad alzayat on 11/30/15.
//  Copyright © 2015 Mihad Alzayat. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource  {
    
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var genderTextField: CustomUITextField!
    @IBOutlet weak var ageTextField: CustomUITextField!
    @IBOutlet weak var termsOfServiceAndPrivacyPolicyLink: UITextView!
    
    // Picker views 
    let genderPickerView = UIPickerView()
    let agePickerView = UIPickerView()
    
    // Data source for picker views
    let genderPickerData = ["Male", "Female"]
    var agePickerData = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize range of ages in age array
        for var i = 16; i <= 100 ; i++ {
            agePickerData.append(i)
        }
        
        // Make corners of get started button rounded
        self.getStartedButton.layer.cornerRadius = 4
       
        // Set the logo image for logoImage variable
        //self.logoImage.image = UIImage(named: "Signup")
        
        self.genderTextFieldConfig()
        self.ageTextFieldConfig()
        self.genderPickerViewConfig()
        self.agePickerViewConfig()
        self.termsAndServicesLinkConfig()
        
        // Make gender text field first responder as soon as the view loads
        self.genderTextField.becomeFirstResponder()
    }
    
    // The get started button is clicked
    @IBAction func getStartedClicked(sender: UIButton) {
        
        self.ageTextField.resignFirstResponder()
        self.genderTextField.resignFirstResponder()
        
        // Check if age field is empty
        if ageTextField.text == "" {
            // Initialize the alert controller and add title and message
            let alertController = UIAlertController(title: "Invalid Input", message: "Please double check that you have entered your gender and age properly.", preferredStyle: .Alert)
            
            // Creat the alert action
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            
            // Add the alert action to the alert controller
            alertController.addAction(okAction)
            
            // Display the alert controller on the screen
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            
            // Change NotFirstLaunch key to true in NSUserDefaults
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(true, forKey: "NotFirstLaunch")
            
            // Add the users age and gender to NSUserDefaults to use in settings
            defaults.setInteger(Int(self.ageTextField.text!)!, forKey: "Age")
            defaults.setObject(self.genderTextField.text, forKey: "Gender")
        
            self.signUpRequest()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mapViewController = storyboard.instantiateViewControllerWithIdentifier("Navigation Controller")
            
            let window = UIApplication.sharedApplication().delegate?.window!
            window?.rootViewController = mapViewController
            
            //print(KeychainManager.stringForKey("token")!)
        
        }
        
    }
    
    // Configure request over the network 
    func signUpRequest() {
    
        // Get the UUID associated with the current device
        let UUID = UIDevice.currentDevice().identifierForVendor?.UUIDString
        
        // Configuration for session object
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        // Initialize session object with its configuration
        let session = NSURLSession(configuration: config)
        
        // The URL which the endpoint can be found at
        let URL = NSURL(string: "http://api.hotspotsapp.us/register")
        
        // Initialize the request with the URL
        let request = NSMutableURLRequest(URL: URL!)
        
        // Configuring the request
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var gender = String()
        self.genderTextField.text! == "Male" ? (gender = "M") : (gender = "F")
        
        print("Gender = \(gender)")
        
        let age = Int(self.ageTextField.text!)!
        
        print("age = \(age)")
        
        // Parameters sent to the server
        let params: [String: AnyObject] = ["gender": gender, "age": age, "UUID": UUID!]
        
        // Turning your data into JSON format and storing in HTTP request body
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
        } catch {
            print("Error serializing data with json object")
        }
        
        // Making a request over the network with request
        // Returns data, response, error objects
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
        
            // Checking HTTP Response in case of error
            let httpResponse = response as? NSHTTPURLResponse
            
            if httpResponse?.statusCode != 200 {
                print(httpResponse?.statusCode)
            }
            
            // Checking if error is nil 
            if error != nil {
                print("Localized description error: \(error?.localizedDescription)")
            }
            
            do {
                // Store JSON data into dictionary
                let JSONDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSMutableDictionary
                
                let token = JSONDictionary!["token"]! as! String
                let userID = JSONDictionary!["ID"]!
                
                if KeychainManager.stringForKey("userID") != nil { KeychainManager.delete("userID") }
                
               
                KeychainManager.setString(userID.stringValue, forKey: "userID")
                KeychainManager.setString( "Bearer " + token, forKey: "token")
            } catch {
                print("catch")
            }
        }
        
        // Start the session
        task.resume()
        
    }
    
    // MARK: - UIResponder
    
    // Dismisses keyboard when someone clicks outside of form fields
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Custom functions 
    
    func genderTextFieldConfig() {
        
        // Setting the input view for the gender text field to a UIPickerView
        self.genderTextField.inputView = self.genderPickerView
        
        // Setting the gender text field's delegate 
        self.genderTextField.delegate = self
        
        // Clears the text field when something new is inserted
        self.genderTextField.clearsOnInsertion = true
    
        // Centers text in text field 
        self.genderTextField.textAlignment = .Center
        
        // Hide cursor in text field
        self.genderTextField.tintColor = UIColor.clearColor()
        
    }
    
    func ageTextFieldConfig() {
        
        // Setting the input view for the age text field to a UIPickerView
        self.ageTextField.inputView = self.agePickerView
        
        // Setting the age text field's delegate 
        self.ageTextField.delegate = self
        
        // Clears the text field when something new is inserted
        self.ageTextField.clearsOnInsertion = true
        
        // Centers text in text field 
        self.ageTextField.textAlignment = .Center
        
        // Hide cursor in text field
        self.ageTextField.tintColor = UIColor.clearColor()
    }
   
    func genderPickerViewConfig() {
        
        // Highlights the selection
        self.genderPickerView.showsSelectionIndicator = true
        
        // Set the delegate and data source for the picker view
        self.genderPickerView.delegate = self
        self.genderPickerView.dataSource = self
    }
    
    func agePickerViewConfig() {
        
        // Highlights the selection
        self.agePickerView.showsSelectionIndicator = true
        
        // Set the delegate and data source for the picker view
        self.agePickerView.delegate = self
        self.agePickerView.dataSource = self
    }
    
    func termsAndServicesLinkConfig() {
        /*
        // Does not allow the user to edit the text view
        self.termsOfServiceAndPrivacyPolicyLink.editable = false
        
        // Link
        //self.termsOfServiceAndPrivacyPolicyLink.dataDetectorTypes = .Link
        
        var stringWithLink = NSMutableAttributedString()
        
        stringWithLink.addAttribute(NSLinkAttributeName, value: "http://Google.com", range: NSMakeRange(0, stringWithLink.length))
        
        stringWithLink = NSMutableAttributedString(string: "By logging in you're agreeing to Terms of Use and Privacy Policy")
        
        self.termsOfServiceAndPrivacyPolicyLink.attributedText = stringWithLink
        */
    }
    
    // MARK: - UITextFieldDelegate 
    
    // Set the first value of the picker view as the default in text field
    func textFieldDidBeginEditing(textField: UITextField) {
        // Check to see which text field is first responder
        if textField == genderTextField {
            // Check to see if the text field is already populated
            if textField.text == "" {
                textField.text = self.genderPickerData[0]
            }
        } else {
            // Check to see if the text field is already populated
            textField.text = String(self.agePickerData[0])
        }
        
    }
    
    // MARK: - UIPickerViewDataSource 
    
    // The number of columns in the picker view
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows in the picker view
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        // Check which picker view is calling the delegate and return the number of rows
        if pickerView == genderPickerView {
            return genderPickerData.count
        } else {
            return agePickerData.count
        }
    }
    
    // MARK: - UIPickerViewDelegate 
    
    // A picker view row was selected
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // Check which picker view is calling the delegate
        if pickerView == genderPickerView {
            // Set the value of the text field to the row selected
            self.genderTextField.text = self.genderPickerData[row]
        } else {
            // Set the value of the text field to the row selected
            self.ageTextField.text = String(self.agePickerData[row])
        }
    }
    
    // Insert title for each row
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        // Check which picker view is calling the delegate 
        if pickerView == genderPickerView {
            return NSAttributedString(string: self.genderPickerData[row])
        } else {
            return NSAttributedString(string: String(self.agePickerData[row]))
        }
    }
    
    

}
