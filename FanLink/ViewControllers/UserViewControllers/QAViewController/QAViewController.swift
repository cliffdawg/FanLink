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

/* Manages the questions pages from the side of the participant */
class QAViewController: UITableViewController {
    
    var ref = FIRDatabase.database().reference()
    var items = [FIRDataSnapshot]()
    var dates = [String]()
    var questions = [String]()
    {
        didSet{
            tableView.reloadData()
        }
    }
    
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
            self.questions = questionsTemp.reversed()
            self.dates = datesTemp.reversed()
        }
    }
    
    // Sets up each question cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell") as! QuestionCell
        cell.questionLabel.text = questions[indexPath.row]
        cell.dateLabel.text = dates[indexPath.row]
        cell.configure()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    // Prepares a replies page upon pressing a question
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "viewDetail" {
                let indexPath = self.tableView.indexPathForSelectedRow
                let cell = self.tableView.cellForRow(at: indexPath!) as! QuestionCell
                let text = cell.questionLabel.text
                let detail = segue.destination as! DisplayQuestionViewController
                detail.questionText = text
            }
        }
    }
}
