//
//  QAViewController.swift
//  FanLink
//
//  Created by Clifford Yin on 4/1/17.
//  Copyright © 2017 Clifford Yin. All rights reserved.
//

import Foundation
import UIKit
import Firebase

/* Handles all the replies to a question */
class ResponseTableViewController: UITableViewController {
    
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResponseCell") as! ResponseCell
        cell.responseLabel.sizeToFit()
        cell.responseLabel.text = responses[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return responses.count
    }
}
