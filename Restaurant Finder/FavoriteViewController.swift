//
//  FavoriteViewController.swift
//  Restaurant Finder
//
//  Created by Jianxin Gao on 5/20/16.
//  Copyright © 2016 Jianxin Gao. All rights reserved.
//

import Foundation
import UIKit
import Notie
import Parse
import LinearProgressBar

class FavoriteViewController: UITableViewController {
    var businesses: [Business] = []
    var businessObjects: [PFObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 86
        
        self.navigationItem.title = "Favorites"
        // add a 'Edit' button in the navigation bar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: #selector(FavoriteViewController.toggleEdittingMode))
        
        // add a 'Refresh' button in the navigation bar
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Refresh", style: .Plain, target: self, action: #selector(FavoriteViewController.refreshData))
    }
    
    func queryLocalDB() {
        // progress bar
        let progressBar = LinearProgressBar()
        self.view.addSubview(progressBar)
        progressBar.startAnimation()
        
        // query the local db for favorited businesses
        let query = PFQuery(className:"FavoriteRestaurant")
        query.fromLocalDatastore()
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            // stop the progress bar animation
            progressBar.stopAnimation()
            
            if error == nil {
                print("Retrieved \(objects!.count) objects from local db")
                if objects?.count > 0 {
                    self.businessObjects = objects!
                    self.businesses = []
                    for object in objects! {
                        let business = Business(name: object["name"] as! String, address: object["address"] as! String, imageURL: object["imageURL"] as! String, ratingImageURL: object["ratingImageURL"] as! String, reviewCount: object["reviewCount"] as! NSNumber, snippetURL: object["snippetURL"] as! String, snippetText: object["snippetText"] as! String, phone: object["phone"] as! String, googleStaticMapURL: object["googleStaticMapURL"] as! String, rating: object["rating"] as! String, latitude: object["latitude"] as! String, longitude: object["longitude"] as! String)
                        self.businesses.append(business)
                    }
                } else {
                    // set the data to empty
                    self.businesses = []
                    self.businessObjects = []
                    
                    let notie = Notie(view: self.view, message: "No favorite restaurant yet.", style: .Confirm)
                    notie.leftButtonAction = {
                        notie.dismiss()
                    }
                    notie.rightButtonAction = {
                        notie.dismiss()
                    }
                    notie.show()
                }
            }
            
            // remember to reload data
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // to reveal the tab bar, otherwise it'll remain hidden since it's hidden in the detail page
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // reload data each time
        queryLocalDB()
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
        //cell.distanceLabel.text = business.distance
        
        return cell
    }
    
    // method to dismiss this view itself, called when `done` button clicked
    func dismissSelf() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // pass the selected UITableViewCell to the detail VC so info can be displayed
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "favSegue" {
            let index = tableView.indexPathForSelectedRow
            let cell = tableView.cellForRowAtIndexPath(index!) as! BusinessCell
            let vc = segue.destinationViewController as! DetailViewController
            let b = businesses[index!.row]
            
            //vc.isFavorite = true
            //this would trigger the property observer in vc and it attempts to access 
            //the favorite button outlet, which will be nil until viewDidLoad
            
            vc.isFromFavorite = true
            
            vc.business = b
            vc.cell = cell
            vc.object = businessObjects[index!.row]
        }
    }
    
    func toggleEdittingMode() {
        if editing {
            self.navigationItem.rightBarButtonItem?.title = "Edit"
            setEditing(false, animated: true)
        }
        else {
            self.navigationItem.rightBarButtonItem?.title = "Done"
            setEditing(true, animated: true)
        }
    }
    
    func refreshData() {
        queryLocalDB()
    }
    
    // delete feature
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            let objToDelete = businessObjects[indexPath.row]
            
            let title = "Remove from favorites"
            let message = "Are you sure you want to remove this favorite restaurant?"
            let ac = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: { (action) -> Void in
                self.businesses.removeAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                objToDelete.unpinInBackground()
            })
            ac.addAction(cancelAction)
            ac.addAction(deleteAction)
            
            presentViewController(ac, animated: true, completion: nil)
        }
    }
}