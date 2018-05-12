//
//  QuestionCell.swift
//  FanLink
//
//  Created by Clifford Yin on 4/1/17.
//  Copyright © 2017 Clifford Yin. All rights reserved.
//

import Foundation
import UIKit
import Firebase

/* Code that consitutes a "question" entity */
class QuestionCell: UITableViewCell {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var replies: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var ref = FIRDatabase.database().reference()
    
    func configure () {
    self.ref.child("Q&A").child(StaticVariables.currentEventQR).child(questionLabel.text!).observe(.value) { (snapshot: FIRDataSnapshot!) in
            var count = 0
            for item in snapshot.children {
                self.replies.text = "\(count) replies"  // Shows how many replies there are on a subscript
                count += 1
            }
        }
    }
}
