//
//  DetailViewController.swift
//  Restaurant Finder
//
//  Created by Jianxin Gao on 5/20/16.
//  Copyright © 2016 Jianxin Gao. All rights reserved.
//

import Foundation
import UIKit
import Parse

class DetailViewController: UIViewController {
    var business: Business!
    var cell: BusinessCell?
    var object: PFObject?
    var isFromFavorite: Bool?
    var isFavorite: Bool? {
        didSet {
            if isFavorite! {
                favButton.select()
            }
        }
    }
    
    @IBOutlet var googleStaticImageView: UIImageView!
    @IBOutlet var snippetLabel: UILabel!
    @IBOutlet var snippetImageView: UIImageView!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    @IBOutlet var reviewCountsLabel: UILabel!
    @IBOutlet var ratingImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var restaurantImageView: UIImageView!
    @IBOutlet var favButton: DOFavoriteButton!
    @IBOutlet var addressLabel: UILabel!
    
    
    @IBAction func favButtonClicked(sender: DOFavoriteButton) {
        if sender.selected {
            // deselect
            isFavorite = false
            sender.deselect()
        } else {
            // select with animation
            isFavorite = true
            sender.select()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let fav = isFromFavorite {
            if fav {
                isFavorite = true
            }
        } else {
            isFavorite = false
        }
        
        navigationItem.title = business.name
        
        Util.downloadImage(business.snippetURL!, imageView: snippetImageView)
        Util.downloadImage(business.googleStaticMapURL!, imageView: googleStaticImageView)
        var snippet = business.snippetText!.stringByReplacingOccurrencesOfString("\n", withString: " ")
        snippet = snippet.substringToIndex(snippet.startIndex.advancedBy(70))
        snippetLabel.text = "\"\(snippet)...\""
        
        distanceLabel.text = business.distance
        phoneLabel.text = business.phone
        reviewCountsLabel.text = "\(business.reviewCount!) reviews"
        if let cell = cell {
            ratingImageView.image = cell.ratingImage.image
            restaurantImageView.image = cell.businessImage.image
        } else {
            Util.downloadImage(business.ratingImageURL!, imageView: ratingImageView)
            Util.downloadImage(business.imageURL!, imageView: restaurantImageView)
        }
        nameLabel.text = business.name
        addressLabel.text = business.address
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // to hide the tab bar
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isFavorite! {
            if object == nil {
                let object = PFObject(className:"FavoriteRestaurant")
                object["name"] = business.name
                object["address"] = business.address
                object["imageURL"] = business.imageURL?.absoluteString
                object["ratingImageURL"] = business.ratingImageURL?.absoluteString
                object["reviewCount"] = business.reviewCount
                object["snippetURL"] = business.snippetURL?.absoluteString
                object["snippetText"] = business.snippetText
                object["phone"] = business.phone
                object["googleStaticMapURL"] = business.googleStaticMapURL?.absoluteString
                object["rating"] = business.rating
                object["latitude"] = business.latitude
                object["longitude"] = business.longitude
                
                object.pinInBackground()
            }
        }
        else {
            if let object = object {
                print("unpinning")
                object.unpinInBackground()
            }
        }
    }
}