//
//  DisplayQuestionViewController.swift
//  FanLink
//
//  Created by Clifford Yin on 4/1/17.
//  Copyright © 2017 Clifford Yin. All rights reserved.
//

import Foundation
import UIKit
import Firebase

/* Code to contain the Replies page */
class DisplayQuestionViewController: UIViewController {
    
    @IBOutlet weak var questionLabel: UILabel!
    
    var questionText: String?
    
    override func viewDidLoad() {
        questionLabel.text = questionText
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "myEmbeddedSegue" {
                let detail = segue.destination as! ResponseTableViewController
                detail.currentQuestion = questionText
            }
        }
    }
}
