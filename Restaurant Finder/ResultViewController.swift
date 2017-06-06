//
//  ResultViewController.swift
//  Restaurant Finder
//
//  Created by Jianxin Gao on 5/20/16.
//  Copyright © 2016 Jianxin Gao. All rights reserved.
//

import Foundation
import UIKit
import LinearProgressBar
import Parse

class ResultViewController: UITableViewController {
    var businesses: [Business] = []
    
    // for query parameters
    var keyword: String = ""
    var sortMode: YelpSortMode = .Distance
    var longitude: String!
    var latitude: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 86
        
        self.navigationItem.title = "Results"
        // add a 'Done' button in the navigation bar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(ResultViewController.dismissSelf))
        
        // progress bar animation
        let progressBar = LinearProgressBar()
        self.view.addSubview(progressBar)
        progressBar.startAnimation()
        
        
        // start the search
        YelpClient.sharedInstance.location = latitude + "," + longitude
        Business.searchWithTerm(keyword, sort: sortMode, categories: [], deals: false) { (businesses: [Business]!, error: NSError!) -> Void in
            
            progressBar.stopAnimation()
            self.businesses = businesses
            self.tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        let business = businesses[indexPath.row]
        
        cell.nameLabel.text = business.name
        cell.addressLabel.text = business.address
        Util.downloadImage(business.imageURL!, imageView: cell.businessImage)
        Util.downloadImage(business.ratingImageURL!, imageView: cell.ratingImage)
        cell.ratingLabel.text = business.rating
        cell.distanceLabel.text = business.distance
        
        return cell
    }
    
    // method to dismiss this view itself, called when `done` button clicked
    func dismissSelf() {
        dismissViewControllerAnimated(true, completion: nil)
    }
        
    // pass the selected UITableViewCell to the detail VC so info can be displayed
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailSegue" {
            let index = tableView.indexPathForSelectedRow
            let cell = tableView.cellForRowAtIndexPath(index!) as! BusinessCell
            let vc = segue.destinationViewController as! DetailViewController
            let b = businesses[index!.row]
            
            let query = PFQuery(className:"FavoriteRestaurant")
            query.fromLocalDatastore()
            query.whereKey("name", equalTo: b.name!)
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    print("Retrieved \(objects!.count) objects from local db")
                    if objects?.count > 0 {
                        vc.object = objects![0]
                        vc.isFavorite = true
                    } else {
                        vc.isFavorite = false
                    }
                }
            }
            
            vc.business = b
            vc.cell = cell
        }
    }
}