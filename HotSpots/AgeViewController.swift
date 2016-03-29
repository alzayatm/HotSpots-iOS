//
//  AgeViewController.swift
//  HotSpots
//
//  Created by mihad alzayat on 1/7/16.
//  Copyright © 2016 Mihad Alzayat. All rights reserved.
//

import UIKit

class AgeViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var textField: CustomUITextField!
    let agePickerView = UIPickerView()
    var agePickerData = [Int]()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for i in 16...100 {
            agePickerData.append(i)
        }
        
        self.ageTextFieldConfig()
        self.agePickerConfig()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.textField.becomeFirstResponder()
        self.agePickerView.selectRow(defaults.integerForKey("Age") - 16, inComponent: 0, animated: true)
    }
    
    func ageTextFieldConfig() {
        
        // Setting the input view for the age text field to a UIPickerView
        self.textField.inputView = self.agePickerView
        
        // Setting the age text field's delegate
        self.textField.delegate = self
        
        // Clears the text field when something new is inserted
        self.textField.clearsOnInsertion = true
        
        // Centers text in text field
        self.textField.textAlignment = .Center
        
        // Hide cursor in text field
        self.textField.tintColor = UIColor.clearColor()
        
        // Make text field font size larger
        self.textField.font = self.textField.font?.fontWithSize(17)
    }
    
    func agePickerConfig() {
        
        // Highlights the selection
        self.agePickerView.showsSelectionIndicator = true
        
        // Set the delegate and data source for the picker view
        self.agePickerView.delegate = self
        self.agePickerView.dataSource = self
    }

    // MARK: - UIResponder
    
    // Dismisses keyboard when someone clicks outside of form fields
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.tableView.endEditing(true)
    }
    
    // MARK: - TextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        var currentAge = String()
        if textField.text == "" {
            for age in self.agePickerData {
                if String(age) == String(defaults.objectForKey("Age")!) {
                    currentAge = String(age)
                    break
                }
            }
            
            textField.text = currentAge
        }
    }
    
    // MARK: - UIPickerViewDataSource
    
    // The number of columns in the picker view
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows in the picker view
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.agePickerData.count
    }
    
    // MARK: - UIPickerViewDelegate
    
    // A picker view row was selected
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
            // Set the value of the text field to the row selected
            self.textField.text = String(self.agePickerData[row])
        
    }
    
    // Insert title for each row
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
            return NSAttributedString(string: String(self.agePickerData[row]))
    }
    
    override func viewWillDisappear(animated: Bool) {
        print(self.textField.text!)
        defaults.setInteger(Int(self.textField.text!)!, forKey: "Age")
        self.updateAgeReq()
    }
    
    func updateAgeReq() {
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        let URL = NSURL(string: "http://api.hotspotsapp.us/updateage")
        let request = NSMutableURLRequest(URL: URL!)
        
        // Configuring the request
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(KeychainManager.stringForKey("token")! as String, forHTTPHeaderField: "Authorization")
        
        
        // Parameters sent to the server
        let age = defaults.objectForKey("Age") as! Int
        print("new age: \(age)")
        let params: [String: AnyObject] = ["age": age, "userID": KeychainManager.stringForKey("userID")!]
        
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
        }
        
        // Start the session
        task.resume()
    }
}
