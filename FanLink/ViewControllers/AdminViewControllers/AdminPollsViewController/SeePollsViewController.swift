//
//  PollViewController.swift
//  FanLink
//
//  Created by Clifford Yin on 4/1/17.
//  Copyright © 2017 Clifford Yin. All rights reserved.
//

import Foundation
import UIKit
import Firebase

/* Code to manage the admin side of viewing and interacting with the polls */
class SeePollsViewController: UITableViewController {
    @IBAction func unwindToSeePollsViewController() {}

    var limit = 0
    var counts = [Int]()
    var ref = FIRDatabase.database().reference()
    var titles = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160
        load()
        self.tableView.allowsSelection = false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "seePollCell") as! SeePollCell
        let titled = titles[indexPath.row]
        cell.configure(polltitled: titled)
        return cell
    }
    
    // Adjusts height according to number of options
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return CGFloat((AdminRowHeightCounter.sharedInstance.counters[indexPath.row])*62+49)
    }

    // Loads the poll options
    func load(){
        
        ref.child("poll").child(StaticVariables.currentEventQR).observe(.value) { (snapshot: FIRDataSnapshot!) in
            
            var titlesTemp = [String]()
            var limit = 0
            for item in snapshot.children {
                
                let childSnapshot = snapshot.childSnapshot(forPath: (item as AnyObject).key)
                let titleID = childSnapshot.key
                titlesTemp.append(titleID)
                limit += 1
                
                if (limit == Int(snapshot.childrenCount)){
                    self.titles = titlesTemp
                    self.tableView.reloadData()
                }
            }
        }
    }

    // Admin can delete a poll
    override func tableView(_ tableView: UITableView, commit: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let titleLabel = self.titles[indexPath.row]
        if UITableViewCellEditingStyle.delete == .delete {
            
            self.ref.child("poll").child(StaticVariables.currentEventQR).observe(.value) { (snapshot: FIRDataSnapshot!) in
                for item in snapshot.children {
                    
                    let childSnapshot = snapshot.childSnapshot(forPath: (item as AnyObject).key)
                    let title = childSnapshot.key
                    
                    if titleLabel == title {
                        (item as AnyObject).ref.removeValue()
                    }
                }
            }
        }
    }
}
