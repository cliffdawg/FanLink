//
//  PollsViewController.swift
//  FanLink
//
//  Created by Clifford Yin on 4/1/17.
//  Copyright © 2017 Clifford Yin. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Charts

/* Manages the polls from the participant's side */
class PollsViewController: UITableViewController, RefreshViewControllerDelegate {
    
    var counts = [Int]()
    var ref = FIRDatabase.database().reference()
    var titles = [String]() {didSet{
        tableView.reloadData()
        }
    }
    var totalRows = [Int]()
    var pressedIndexes = [Int]()
    
    func refresh(_ add: Int) {
        pressedIndexes.append(add)
        var input = [Int]()
        for valued in totalRows {
            if (pressedIndexes.contains(valued) == false) {
                input.append(valued)
            }
        }
    
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            for value in input {
                let rowed = self.tableView.cellForRow(at: IndexPath(row: value, section: 0))?.contentView
            }
        }
    }
    
    
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "pollCell") as! PollCell
        let titled = titles[indexPath.row]
        if (pressedIndexes.contains(indexPath.row) == false) {
            cell.configure(polltitled: titled, num: indexPath.row)
        } else {
            cell.configure2(polltitle: titled, number: indexPath.row)
        }
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat((RowHeightCounter.sharedInstance.counters[indexPath.row])*62+59)
    }
    
    func loadCounts() {
        for i in self.titles {
            
            self.ref.child("poll").child(StaticVariables.currentEventQR).child(i).observe(.value) { (snapshot: FIRDataSnapshot!) in
                    var counter = 0
                    for item in snapshot.children {
                        counter += 1
                }
              self.counts.append(counter)
            }
        }
    }

    func load(){
        
        ref.child("poll").child(StaticVariables.currentEventQR).observe(.value) { (snapshot: FIRDataSnapshot!) in
            var titlesTemp = [String]()
            var count = 0
            for item in snapshot.children {
                let childSnapshot = snapshot.childSnapshot(forPath: (item as AnyObject).key)
                let titleID = childSnapshot.key
                titlesTemp.append(titleID)
                self.totalRows.append(count)
                count += 1
            }
            self.titles = titlesTemp
            self.loadCounts()
        }
    }
}
