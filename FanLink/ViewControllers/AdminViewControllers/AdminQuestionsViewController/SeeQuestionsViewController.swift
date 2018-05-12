//
//  SeeQuestionsViewController.swift
//  FanLink
//
//  Created by Clifford Yin on 4/1/17.
//  Copyright © 2017 Clifford Yin. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Whisper

/* Sets up the replies on the admin side of the Q&A page */
class SeeQuestionsViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var replyField: UITextField!
    var questionText: String?
    
    override func viewDidLoad() {
        questionLabel.text = questionText
        replyField.delegate = self as UITextFieldDelegate
    }
    
    // Before posting a reply, the admin must type one
    @IBAction func postPressed(_ sender: Any) {
        let ref = FIRDatabase.database().reference()
        if (replyField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! == true {
            guard let navigationController = self.navigationController else { return }
            let message = Message(title: "Write something first!", backgroundColor: .red)
            Whisper.show(whisper: message, to: navigationController, action: .show)
        } else {
            let post = replyField.text
        ref.child("Q&A").child(StaticVariables.currentEventQR).child(questionText!).childByAutoId().setValue(post)
        }
        replyField.text = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "embeddedSegue" {
                let detail = segue.destination as! RepliesViewController
                let text = questionText ?? questionLabel.text
                detail.currentQuestion = text
            }
        }
    }
    
    // The reply can have a maximum of 302 characters
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = replyField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 302
    }
}
