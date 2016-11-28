//
//  PersonalityInsightsAPI.swift
//  IOTYelp
//
//  Created by Alla Bondarenko on 2016-11-17.
//  Copyright © 2016 Alla Bondarenko. All rights reserved.
//

import UIKit
import CoreLocation


protocol BluemixAPIControllerProtocol {
    func didRecievePersonalityInsightsResults(_ results: [[String: Any]], error: Error?)
}


class PersonalityInsightsAPI{
    
    var delegate: BluemixAPIControllerProtocol
    
    init(delegate: BluemixAPIControllerProtocol){
        self.delegate = delegate
    }
    
    // Perform request to Personality Insights Service Instance
    func getPersonalityProfile(personalityData: [String]){
        let session = URLSession.shared
        
        var url = URLComponents()
        url.scheme = "https"
        url.host = "gateway.watsonplatform.net"
        url.path = "/personality-insights/api/v3/profile"
        
        url.queryItems = [
            URLQueryItem(name:"version", value: "2016-10-20"),
            URLQueryItem(name:"consumption_preferences", value: "true"),
            URLQueryItem(name:"raw_scores", value: "true")
        ]

        
        let request: NSMutableURLRequest = NSMutableURLRequest(url: url.url!)
        
        request.httpMethod = "POST"
        
        let username = ""
        let password = ""
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        var contentItems = [Any]()
        
        for post in personalityData {
            var contentItem = [String: Any]()
            contentItem["content"] = post
            contentItems.append(contentItem)
        }
        let jsonObject : [String: Any] = ["contentItems": contentItems]
        
        if (JSONSerialization.isValidJSONObject(jsonObject)) {
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted)
                request.addValue("application/json", forHTTPHeaderField: "Accept")
            } catch {
                print("Error: \(error)")
                return
            }
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if (error != nil){
                print(error?.localizedDescription ?? "error performing URL Request")
                self.delegate.didRecievePersonalityInsightsResults([], error: error)
            }
            
            if let data = data,
                let jsonResult = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {

                if let consumptionNeeds = jsonResult!["consumption_preferences"] as? [[String:Any]] {
                    for need in consumptionNeeds {
                        //parse response only for shopping preferences
                        if let category = need["consumption_preference_category_id"] as? String {
                            if (category == "consumption_preferences_health_and_activity"), let consumptionPreferences = need["consumption_preferences"] as? [[String: Any]] {
                            print("consumptionNeeds")
                            self.delegate.didRecievePersonalityInsightsResults(consumptionPreferences, error: nil)
                            }
                        }
                    }
                } else {

                    print("unauthorized/ invalid request")
                    return
                }
            }
            
        })
        task.resume()
    }

}
