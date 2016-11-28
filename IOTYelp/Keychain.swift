//
//  Keychain.swift
//  IOTYelp
//
//  Created by Alla Bondarenko on 2016-11-16.
//  Copyright © 2016 Alla Bondarenko. All rights reserved.
//

import Foundation
import Security

public class Keychain {
   
    
    public class func set(key: String, value: String) -> Bool {
        if let data = value.data(using: .utf8) {
            SecItemDelete(deleteQuery(key: key))
            return SecItemAdd(updateQuery(key: key, value: data as NSData), nil) == noErr
        }
        return false
    }
    
    public class func get(key: String) -> NSString? {
        let query = searchQuery(key: key)
        if let data = getData(query: query){
            //encoding conversion -> refer to SR-2388
            return NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)
        }
        return nil
    }
    
    public class func getData(query: CFDictionary) -> NSData? {
        var response: AnyObject?
        
        let status = withUnsafeMutablePointer(to: &response, {
            SecItemCopyMatching(query, UnsafeMutablePointer($0))
        })
        
        return status == noErr && response != nil
            ? response as! NSData?
            : nil
    }
    
    public class func delete(key: String) -> Bool {
        return SecItemDelete(deleteQuery(key: key)) == noErr
    }
    
    public class func clear() -> Bool {
        if SecItemDelete([(kSecClass as NSString): kSecClassGenericPassword] as CFDictionary) == noErr {
            print("all passwords deleted")
        }
        return SecItemDelete( clearQuery()) == noErr
    }
    
    private class func updateQuery(key: String, value: NSData) -> CFDictionary {
        return NSMutableDictionary(objects: [ kSecClassGenericPassword, key], forKeys: [kSecClass as NSString, kSecAttrAccount as NSString])
    }
    
    private class func deleteQuery(key: String) -> CFDictionary {
        return NSMutableDictionary( objects: [kSecClassGenericPassword, key], forKeys: [kSecClass as NSString, kSecAttrAccount as NSString])
    }
    
    private class func searchQuery(key: String) -> CFDictionary {
        return NSMutableDictionary(objects: [kSecClassGenericPassword, key, kCFBooleanTrue, kSecMatchLimitOne], forKeys: [(kSecClass) as NSString, kSecAttrAccount as NSString, kSecReturnData as NSString, kSecMatchLimit as NSString])
    }
    
    private class func clearQuery() -> CFDictionary {
        return [kSecClass as String : kSecClassGenericPassword] as CFDictionary
    }
    
    
   
}
