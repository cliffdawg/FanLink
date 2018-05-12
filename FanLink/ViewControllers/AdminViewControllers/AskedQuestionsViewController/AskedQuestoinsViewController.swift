//
//  AskedQuestoinsViewController.swift
//  FanLink
//
//  Created by Clifford Yin on 4/1/17.
//  Copyright © 2017 Clifford Yin. All rights reserved.
//

import Foundation
import UIKit
import Firebase

/* Code that represents the admin side of viewing the Q&A page */
class AskedQuestionsViewController: UITableViewController {
    
    var ref = FIRDatabase.database().reference()
    var items = [FIRDataSnapshot]()
    var questions = [String]()
        {
        didSet{
            tableView.reloadData()
        }
    }

    var dates = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref.child("Q&A").child(StaticVariables.currentEventQR).queryOrdered(byChild: "numericDate").observe(.value) { (snapshot: FIRDataSnapshot!) in
            var questionsTemp = [String]()
            var datesTemp = [String]()
            
            for item in snapshot.children {
                let childSnapshot = snapshot.childSnapshot(forPath: (item as AnyObject).key)
                let question = childSnapshot.key
                questionsTemp.append(question)
                let dateValue = childSnapshot.value as? NSDictionary
                if (dateValue?["date"] != nil) {
                    let date = dateValue?["date"] as! String
                    datesTemp.append(date)
                } else {
                    datesTemp.append("")
                }
            }
            
            // Puts them in correct chronological order
            self.questions = questionsTemp.reversed()
            self.dates = datesTemp.reversed()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "questionCell") as! AdminQuestionCell
        cell.questionLabel.text = questions[indexPath.row]
        cell.dateLabel.text = dates[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "segueToDetail" {
                let indexPath = self.tableView.indexPathForSelectedRow
                let cell = self.tableView.cellForRow(at: indexPath!) as! AdminQuestionCell
                let text = cell.questionLabel.text
                let detail = segue.destination as! SeeQuestionsViewController
                detail.questionText = text
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, commit: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let questionLabel = self.questions[indexPath.row]
        
        if UITableViewCellEditingStyle.delete == .delete {
         
            self.ref.child("Q&A").child(StaticVariables.currentEventQR).observe(.value) { (snapshot: FIRDataSnapshot!) in
                for item in snapshot.children {
                    let childSnapshot = snapshot.childSnapshot(forPath: (item as AnyObject).key)
                    let question = childSnapshot.key
                    
                    if questionLabel == question {
                        (item as AnyObject).ref.removeValue()
                        }
                    }
                }
            }
    }
    
}
