//
//  Category.swift
//  IOTYelp
//
//  Created by Alla Bondarenko on 2016-11-21.
//  Copyright © 2016 Alla Bondarenko. All rights reserved.
//

import UIKit

class Category: NSObject, NSCoding {
    
    //MARK: Properties
    
    struct PropertyKey {
        static let idKey = "idkey"
        static let categoryNameKey = "categoryName"
        static let confidenceKey = "confidenceKey"
    }
    
    var id: String
    var categoryName: String
    var confidenceScore: Double
    
    //MARK: Initialization
    
    init?(id: String, categoryName: String, confidenceScore: Double){
        //Initialixe stored properties
        self.id = id
        self.categoryName = categoryName
        self.confidenceScore = confidenceScore
        super.init()
        
        if categoryName.isEmpty {
            return nil
        }
    }
    
    static func parseWithJSON(json: [String: Any]) -> Category? {
        
        for _ in json {
            if let id = json["consumption_preference_id"] as? String {
                let name: String
                switch (id){
                case "consumption_preferences_eat_out":
                    name = "fooddeliveryservices"
                case "consumption_preferences_fast_food_frequency":
                    name = "hotdogs"
                case "consumption_preferences_gym_membership":
                    name = "fitness"
                case "consumption_preferences_adventurous_sports":
                    name = "amusementparks"
                case "consumption_preferences_outdoor":
                    name = "sportgoods"
                default:
                    name = json["name"] as? String ?? "default"
                }
                let confidenceScore = json["score"] as? Double ?? 0
                print(id, " ", name, " ", confidenceScore)
                
                if (confidenceScore != Double(0.0)) {
                    return Category(id: id, categoryName: name, confidenceScore: confidenceScore)
                }
            }
        }
        return nil
    }
    
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: PropertyKey.idKey)
        aCoder.encode(categoryName, forKey: PropertyKey.categoryNameKey)
        aCoder.encode(confidenceScore, forKey: PropertyKey.confidenceKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        var id = aDecoder.decodeObject(forKey: PropertyKey.idKey) as? String
        if (id == nil) {
            id = UUID().uuidString
        }
        let categoryName = aDecoder.decodeObject(forKey: PropertyKey.categoryNameKey) as! String
        let confidenceScore = aDecoder.decodeDouble(forKey: PropertyKey.confidenceKey)
        
        self.init(id: id!, categoryName:categoryName, confidenceScore: confidenceScore)
    }
    
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("categoryNames")
    
}

