//
//  Business.swift
//  IOTYelp
//
//  Created by Alla Bondarenko on 2016-11-16.
//  Copyright © 2016 Alla Bondarenko. All rights reserved.
//

import Foundation
import CoreLocation

class Business {
    var name: String!
    var rating: Int?
    var price: String?
    var phone: String?
    var id: String?
    var isClosed: Bool?
    var coordinates: CLLocation!
    var url: URL! //String?
    var img_url: URL?
    var distance: String?
    var categories: String?
    

    init?(json: [String: Any]) {
        guard let name = json["name"] as? String else {
            return nil
        }
        
        guard let distance = json["distance"] as? Double else {
            return nil
        }
        
        guard let phone = json["phone"] as? String else {
            return nil
        }
        
        guard let isClosed = json["is_closed"] as? Bool else {
            return nil
        }
        
        guard let categories = json["categories"] as? [[String: Any]] else {
            return nil
        }
        
        var categoriesStr = ""
        for category in categories {
            if let category = category["title"] as? String {
                categoriesStr.append("\(category) ")
            }
        }

        guard let img_url = json["image_url"] as? String else {
            return nil
        }
        
        // Extract and validate coordinates
        guard let coordinatesJSON = json["coordinates"] as? [String: Double],
            let latitude = coordinatesJSON["latitude"],
            let longitude = coordinatesJSON["longitude"]
            else {
                return nil
        }
        
        
        self.name = name
        self.distance = String(format: "%.0f", distance).appending(" meters")
        self.phone = phone
        self.isClosed = isClosed
        self.categories = categoriesStr
        self.img_url = URL(string: img_url)
        self.coordinates = CLLocation(latitude: latitude, longitude: longitude)

    }
}

