//
//  NewQuestionViewController.swift
//  FanLink
//
//  Created by Clifford Yin on 4/1/17.
//  Copyright © 2017 Clifford Yin. All rights reserved.
//

import Foundation
import UIKit
import KMPlaceholderTextView
import Firebase
import Whisper

/* Code that manages page for a participant asking a new question */
class NewQuestionViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: KMPlaceholderTextView!
    var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        textView.delegate = self as! UITextViewDelegate
    }
    
    override var inputAccessoryView: UIView? {
        toolbar = UIToolbar()
        toolbar.isTranslucent = false
        toolbar.tintColor = UIColor.black
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let postButton = UIBarButtonItem(title: "POST", style: .plain, target: self, action: #selector(NewQuestionViewController.uploadPost))
        postButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 16.0)!, NSForegroundColorAttributeName: UIColor.init(red: 22/255, green: 166/255, blue:228/255, alpha: 1.0)], for: UIControlState())
        toolbar.items = [space, postButton]
        toolbar.sizeToFit()
        return toolbar
    }
    
    // Limits question characters to 102
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        return ((numberOfChars < 103) && !(newText.contains(".")) && !(newText.contains("#")) && !(newText.contains("$")) && !(newText.contains("[")) && !(newText.contains("]")))
    }

    // Stores the new question in Firebase
    func uploadPost() {
        let ref = FIRDatabase.database().reference()
        if (self.textView.text?.trimmingCharacters(in: .whitespaces).isEmpty)! == true {
            guard let navigationController = self.navigationController else { return }
            let message = Message(title: "Write something first!", backgroundColor: .red)
            Whisper.show(whisper: message, to: navigationController, action: .show)
        }
        else { // Datestamp it
            let post = textView.text
            let timeFormatter = DateFormatter()
            let timeFormatter2 = DateFormatter()
            timeFormatter.dateStyle = DateFormatter.Style.short
            timeFormatter.timeStyle = DateFormatter.Style.short
            
            let strDate = timeFormatter.string(from: Date())
            timeFormatter2.dateFormat = "M/dd/yyyy, h:mm a"
            let numericDate = timeFormatter2.string(from: Date())
            let stringDate = numericDate
            
            let dated = Date().timeIntervalSince1970 as Double
            ref.child("Q&A").child(StaticVariables.currentEventQR).child(post!).setValue(["date": stringDate, "numericDate": dated])
        }
        let _ = self.navigationController?.popViewController(animated: true)
    }
}
