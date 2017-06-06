//
//  Business.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class Business: NSObject {
    let name: String?
    let address: String?
    let imageURL: NSURL?
    let categories: String?
    let distance: String?
    let ratingImageURL: NSURL?
    let reviewCount: NSNumber?
    let snippetURL: NSURL?
    let snippetText: String?
    let phone: String?
    let googleStaticMapURL: NSURL?
    let rating: String?
    let latitude: String
    let longitude: String
    
    init(name: String, address: String, imageURL: String, ratingImageURL: String, reviewCount: NSNumber, snippetURL: String, snippetText: String, phone: String, googleStaticMapURL: String, rating: String, latitude: String, longitude: String) {
        self.name = name
        self.address = address
        self.imageURL = NSURL(string: imageURL)
        self.categories = nil
        self.distance = ""
        self.ratingImageURL = NSURL(string: ratingImageURL)
        self.reviewCount = reviewCount
        self.snippetURL = NSURL(string: snippetURL)
        self.snippetText = snippetText
        self.phone = phone
        self.googleStaticMapURL = NSURL(string: googleStaticMapURL)
        self.rating = rating
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(dictionary: NSDictionary) {
        name = dictionary["name"] as? String
        snippetText = dictionary["snippet_text"] as? String
        rating = String(dictionary["rating"] as! Double)
        
        let imageURLString = dictionary["image_url"] as? String
        if imageURLString != nil {
            imageURL = NSURL(string: imageURLString!)!
        } else {
            imageURL = nil
        }
        if let snippet = dictionary["snippet_image_url"] as? String {
            snippetURL = NSURL(string: snippet)
        } else {
            snippetURL = nil
        }
        
        if let phoneStr = dictionary["display_phone"] as? String {
            phone = phoneStr
        } else {
            phone = nil
        }
        
        let location = dictionary["location"] as? NSDictionary
        var address = ""
        if location != nil {
            let addressArray = location!["address"] as? NSArray
            if addressArray != nil && addressArray!.count > 0 {
                address = addressArray![0] as! String
            }
            
            let neighborhoods = location!["neighborhoods"] as? NSArray
            if neighborhoods != nil && neighborhoods!.count > 0 {
                if !address.isEmpty {
                    address += ", "
                }
                address += neighborhoods![0] as! String
            }
            
            let coordinate = location!["coordinate"] as? NSDictionary
            let latitude = String(coordinate!["latitude"] as! NSNumber)
            let longitude = String(coordinate!["longitude"] as! NSNumber)
            self.latitude = latitude
            self.longitude = longitude
        } else {
            latitude = ""
            longitude = ""
        }
        self.address = address
        
        //let coordinate = Util.forwardGeocoding(address)
        //googleStaticMapURL = NSURL(string: "http://maps.google.com/maps/api/staticmap?markers=color:blue|\(latitude!),\(longitude!)&zoom=13&size=600x400&sensor=true")
        googleStaticMapURL = NSURL(string: "https://maps.googleapis.com/maps/api/staticmap?center=\(latitude),\(longitude)&zoom=19&size=600x400&maptype=roadmap&markers=color:red%7C\(latitude),\(longitude)")
        //print("google static map url: \(googleStaticMapURL)")
        
        let categoriesArray = dictionary["categories"] as? [[String]]
        if categoriesArray != nil {
            var categoryNames = [String]()
            for category in categoriesArray! {
                let categoryName = category[0]
                categoryNames.append(categoryName)
            }
            categories = categoryNames.joinWithSeparator(", ")
        } else {
            categories = nil
        }
        
        let distanceMeters = dictionary["distance"] as? NSNumber
        if distanceMeters != nil {
            let milesPerMeter = 0.000621371
            distance = String(format: "%.2f mi", milesPerMeter * distanceMeters!.doubleValue)
        } else {
            distance = nil
        }
        
        let ratingImageURLString = dictionary["rating_img_url_large"] as? String
        if ratingImageURLString != nil {
            ratingImageURL = NSURL(string: ratingImageURLString!)
        } else {
            ratingImageURL = nil
        }
        
        reviewCount = dictionary["review_count"] as? NSNumber
    }
    
    
    class func businesses(array array: [NSDictionary]) -> [Business] {
        var businesses = [Business]()
        for dictionary in array {
            let business = Business(dictionary: dictionary)
            businesses.append(business)
        }
        return businesses
    }
    
    class func searchWithTerm(term: String, completion: ([Business]!, NSError!) -> Void) {
        YelpClient.sharedInstance.searchWithTerm(term, completion: completion)
    }
    
    class func searchWithTerm(term: String, sort: YelpSortMode?, categories: [String]?, deals: Bool?, completion: ([Business]!, NSError!) -> Void) -> Void {
        YelpClient.sharedInstance.searchWithTerm(term, sort: sort, categories: categories, deals: deals, completion: completion)
    }
}
