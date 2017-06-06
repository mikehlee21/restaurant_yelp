//
//  SearchViewController.swift
//  Restaurant Finder
//
//  Created by Jianxin Gao on 5/20/16.
//  Copyright © 2016 Jianxin Gao. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    let searchBar = UISearchBar()
    let segmentedControl = UISegmentedControl(items: ["By Distance", "By Relevance"])
    var placePicker: GMSPlacePicker?
    var nameLabel = UILabel()
    var addressLabel = UILabel()
    var longitude = "-121.8855007"
    var latitude = "37.3356461"
    
    override func loadView() {
        super.loadView()
        
        // add segmented control
        segmentedControl.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
        
        let margins = view.layoutMarginsGuide
        let topConstraint = segmentedControl.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor, constant: 16)
        let leadingConstraint = segmentedControl.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor)
        let trailingConstraint = segmentedControl.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor)
        
        topConstraint.active = true
        leadingConstraint.active = true
        trailingConstraint.active = true
        
        // add location's name label
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "San Jose Downtown (Default location)"
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.font = UIFont(name: "HelveticaNeue", size: 19.0)
        nameLabel.backgroundColor = view.tintColor
        let topConstraintForNameLabel = nameLabel.topAnchor.constraintEqualToAnchor(segmentedControl.bottomAnchor, constant: 24)
        let leadingConstraintForNameLabel = nameLabel.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor)
        let trailingConstraintForNameLabel = nameLabel.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor)
        topConstraintForNameLabel.active = true
        leadingConstraintForNameLabel.active = true
        trailingConstraintForNameLabel.active = true
        
        // add location's address label
        view.addSubview(addressLabel)
        addressLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        addressLabel.numberOfLines = 0
        addressLabel.textColor = view.tintColor
        addressLabel.font = UIFont(name: "HelveticaNeue", size: 19.0)
        addressLabel.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        let topConstraintForAddressLabel = addressLabel.topAnchor.constraintEqualToAnchor(nameLabel.bottomAnchor, constant: 16)
        let leadingConstraintForAddressLabel = addressLabel.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor)
        let trailingConstraintForAddressLabel = addressLabel.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor)
        topConstraintForAddressLabel.active = true
        leadingConstraintForAddressLabel.active = true
        trailingConstraintForAddressLabel.active = true
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add `place` icon in the navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_location_on"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SearchViewController.locationButtonClicked))
        
        // add the search bar in navigation bar
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.autocorrectionType = .Yes
        navigationItem.titleView = searchBar
    }
    
    // to show a `cancel` button in the search bar
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    // clear existing text and dismiss keyboard when `cancel` clicked
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    // respond to search action
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let resultVC = mainStoryboard.instantiateViewControllerWithIdentifier("resultVC") as! ResultViewController
        // set parameters
        if let keyword = searchBar.text {
            resultVC.keyword = keyword
        }
        resultVC.latitude = latitude
        resultVC.longitude = longitude
        
        if segmentedControl.selectedSegmentIndex != 0 {
            resultVC.sortMode = YelpSortMode.BestMatched
        }
        
        // present the search result VC in a navigation VC
        let navigationVC = UINavigationController(rootViewController: resultVC)
        presentViewController(navigationVC, animated: true, completion: nil)
        searchBar.text = ""
    }
    
    func locationButtonClicked() {
        let center = CLLocationCoordinate2DMake(37.3356461, -121.8855007)
        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
        let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        placePicker = GMSPlacePicker(config: config)
        
        placePicker?.pickPlaceWithCallback({ (place: GMSPlace?, error: NSError?) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                self.nameLabel.text = place.name
                if let address = place.formattedAddress {
                    self.addressLabel.text = address.componentsSeparatedByString(", ").joinWithSeparator("\n")
                } else {
                    self.addressLabel.text = ""
                }
                self.latitude = "\(place.coordinate.latitude)"
                self.longitude = "\(place.coordinate.longitude)"
                
            } else {
                //self.nameLabel.text = "No place selected"
                self.addressLabel.text = ""
            }
        })
    }
    
}
