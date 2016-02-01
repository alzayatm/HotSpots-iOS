//
//  KeychainManager.swift
//  HotSpots
//
//  Created by mihad alzayat on 12/17/15.
//  Copyright © 2015 Mihad Alzayat. All rights reserved.
//


import Foundation
import Security

// Configuring dictionary for adding item

// Type of class
let itemClassKeyConstant = kSecClass as NSString
let itemClassValueConstants = kSecClassGenericPassword as NSString

// The account value
let kSecAttrAccountValue = kSecAttrAccount as NSString

// Keychain accessability
let kSecAttrAccessibleValue = kSecAttrAccessible as NSString
let thisDeviceOnly = kSecAttrAccessibleAlwaysThisDeviceOnly as NSString

// Token
let kSecValueDataValue = kSecValueData as NSString

// Service Value 
let kSecAttrServiceValue = kSecAttrService as NSString


// Configuring dictionary for retrieving item

// Type of item to return
let kSecReturnDataValue = kSecReturnData as NSString

// Number of items to return 
let kSecMatchLimitValue = kSecMatchLimit as NSString
let oneValue = kSecMatchLimitOne as NSString



class KeychainManager {
    
    class func setString(value: NSString, forKey: String) {
        self.saveKeychainItem(key: forKey, data: value)
    }
    
    class func stringForKey(key: String) -> NSString? {
        let keychainItem = self.retrieveKeychainItem(key: key)
        
        return keychainItem
    }
    
    class func delete(key: String) {
        self.deleteKeychainItem(key: key)
    }
    
    private class func saveKeychainItem(key key: String, data: NSString) -> OSStatus {
        
        let dataFromString: NSData = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        
        let keychainQuery: NSMutableDictionary =  NSMutableDictionary(objects: [itemClassValueConstants, "HotSpots", key, dataFromString, thisDeviceOnly], forKeys: [itemClassKeyConstant, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue, kSecAttrAccessibleValue])
        
        let statusCode: OSStatus = SecItemAdd(keychainQuery as CFDictionaryRef, nil)
        
        return statusCode
    }
    
    private class func retrieveKeychainItem(key  key: String) -> NSString? {
        
        
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [itemClassValueConstants, "HotSpots", key, kCFBooleanTrue, oneValue], forKeys: [itemClassKeyConstant, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])
        
        var result = NSData()
        
        let status: OSStatus = withUnsafeMutablePointer(&result) { SecItemCopyMatching(keychainQuery, UnsafeMutablePointer($0)) }
        
        var contentOfKeychain: NSString?
        
        if status == errSecSuccess {
            contentOfKeychain = NSString(data: result, encoding: NSUTF8StringEncoding)
        } else {
            return nil
        }
        
        return contentOfKeychain
    }
    
    
    private class func deleteKeychainItem(key key: String) -> OSStatus {
        
        let keychainQuery: NSMutableDictionary =  NSMutableDictionary(objects: [itemClassValueConstants, "HotSpots", key, thisDeviceOnly], forKeys: [itemClassKeyConstant, kSecAttrServiceValue, kSecAttrAccountValue,  kSecAttrAccessibleValue])
        
        let statusCode: OSStatus = SecItemDelete(keychainQuery as CFDictionaryRef)
        
        return statusCode
    }
    
}