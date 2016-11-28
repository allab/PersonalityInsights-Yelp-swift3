//
//  APIController.swift
//  IOTYelp
//
//  Created by Alla Bondarenko on 2016-11-15.
//  Copyright © 2016 Alla Bondarenko. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftKeychainWrapper


protocol YelpAPIControllerProtocol {
    func didRecieveYelpAPIResults(_ results: [[String: Any]])
    
    func didRecieveYelpApiError(_ error: Error)
}

class YelpAPIController {
    
    var delegate: YelpAPIControllerProtocol
    var clientID = ""
    let clientSecret = ""
    
    
    init(delegate: YelpAPIControllerProtocol){
        self.delegate = delegate
    }

    //Authorization call
    func getAuthToken(callback: @escaping (String) -> ()) {
            let session = URLSession.shared
            
            var url = URLComponents()
            url.scheme = "https"
            url.host = "api.yelp.com"
            url.path = "/oauth2/token"
            let request: NSMutableURLRequest = NSMutableURLRequest(url: url.url!)
            request.httpMethod = "POST"
            
            let parameters = "grant_type=client_credentials&client_id=\(clientID)&&client_secret=\(clientSecret)"
        
            request.httpBody = parameters.data(using:String.Encoding.ascii, allowLossyConversion: false)
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

            let task = session.dataTask(with: request as URLRequest, completionHandler:{(data, response, error) -> Void in
                if (error != nil){
                    print(error?.localizedDescription ?? "error")
                } else {
                    if let data = data,
                        let jsonResult = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            if let token = jsonResult!["access_token"] as? String{
                                print("token assigned")
                                print(jsonResult!["access_token"] ?? "no access token but success")
                                callback(token)
                            return
                        } else {
                            print("unauthorized")
                            return
                        }
                    }
                }
            })
            
            task.resume()

    }
    
    func tokenStored() -> String? {
        var token: String?
        
        if let tokenValue = KeychainWrapper.standard.string(forKey: "yelpToken") {
                return tokenValue
        } else {
            getAuthToken() { (response) in
                token = response
                _ = KeychainWrapper.standard.set(token!, forKey: "yelpToken")
                
            }
            return token
        }
    }
    
    // GET Search API Results
    
    func getBusinessSearch(location: CLLocation, term: String, attributes: [Category]){
        let session = URLSession.shared
        
        guard let tokenValue = tokenStored() else {
            print("failed to retrieve tokenValue")
            return
        }
        
        var url = URLComponents()
        url.scheme = "https"
        url.host = "api.yelp.com"
        url.path = "/v3/businesses/search"
    
        let radius = 5000
        let limit = 10
        let sort_by = "best_match"
        let open_now = true
        
        var attrStr: String = ""
        for attribute in attributes {
            attrStr.append("\(attribute.categoryName),")
        }

        if (attributes.count > 2) {
            attrStr = attrStr.substring(to: attrStr.index(before: attrStr.endIndex))
        }
        print("categories:", attrStr)
        
            url.queryItems = [
                URLQueryItem(name:"term", value: term),
                URLQueryItem(name:"categories", value: attrStr),
                URLQueryItem(name:"latitude", value: String(location.coordinate.latitude)),
                URLQueryItem(name:"longitude", value: String(location.coordinate.longitude)),
                URLQueryItem(name:"radius", value: String(radius)),
                URLQueryItem(name:"limit", value: String(limit)),
                URLQueryItem(name:"sort_by", value: String(sort_by)),
                URLQueryItem(name:"open_now", value: String(open_now))
                ]
            
        
            var request = URLRequest(url: url.url!)
            request.setValue("Bearer \(tokenValue)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "GET"
        
            print("URL \(url)")
        
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error -> Void in
                if (error != nil){
                    print(error?.localizedDescription ?? "error performing URLRequest")
                } else {
                        do{
                            if let data = data,
                                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                                    let name = json["total"] as? Int
                                    if let results = json["businesses"] as? [[String: Any]] {
                                        print("hey", name!, results)
                                        self.delegate.didRecieveYelpAPIResults(results)
                                    } else if let error = json["error"] as? [String:Any] {
                                        print("err \(error)")
                                        self.delegate.didRecieveYelpApiError(error as! Error)
                                    }
                                }
                        }
                        catch {
                            print(error)
                        }
                }
            })
            task.resume()
    }
}



extension String {
    
    func addingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
    
}

extension Dictionary {
    
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).addingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = (value as! String).addingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joined(separator: "&")
    }
    
}
