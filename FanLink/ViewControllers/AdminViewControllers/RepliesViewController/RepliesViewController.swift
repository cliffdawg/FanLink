//
//  RepliesViewController.swift
//  FanLink
//
//  Created by Clifford Yin on 4/1/17.
//  Copyright © 2017 Clifford Yin. All rights reserved.
//

import Foundation
import UIKit
import Firebase

/* Sets up the replies on the user side of the Q&A page */
class RepliesViewController: UITableViewController {
    
    var currentQuestion: String?
    var ref = FIRDatabase.database().reference()
    var items = [FIRDataSnapshot]()
    var responses = [String]()
        {
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref.child("Q&A").child(StaticVariables.currentEventQR).child(currentQuestion!).observe(.value) { (snapshot: FIRDataSnapshot!) in
            
            var answersTemp = [String]()
            for item in snapshot.children {
                let childSnapshot = snapshot.childSnapshot(forPath: (item as AnyObject).key)
                let answer = childSnapshot.value
                if ((childSnapshot.key != "date") && (childSnapshot.key != "answer") && (childSnapshot.key != "numericDate")) {
                answersTemp.append(answer as! String)
                }
            }
            self.responses = answersTemp
        }
    }
    
    // Mark: TableView methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResponseCell") as! AdminReplyCell
        cell.responseLabel.text = responses[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return responses.count
    }
    
    // Admin can remove a reply
    override func tableView(_ tableView: UITableView, commit: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let userReply = self.responses[indexPath.row]
        if UITableViewCellEditingStyle.delete == .delete {
         self.ref.child("Q&A").child(StaticVariables.currentEventQR).child(currentQuestion!).observe(.value) { (snapshot: FIRDataSnapshot!) in
                    for item in snapshot.children {
                        let childSnapshot = snapshot.childSnapshot(forPath: (item as AnyObject).key)
                        let reply = childSnapshot.value as! String
                        if userReply == reply {
                            (item as AnyObject).ref.removeValue()
                        }
                }
            }
        }
    }
    
}
