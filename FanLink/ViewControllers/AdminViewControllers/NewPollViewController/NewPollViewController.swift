//
//  NewPollViewController.swift
//  FanLink
//
//  Created by Clifford Yin on 4/1/17.
//  Copyright © 2017 Clifford Yin. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import KMPlaceholderTextView
import Whisper

/* Code for the admin to generate a new poll */
class NewPollViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    // MARK: Properties
    
    var ref = FIRDatabase.database().reference()
    var titles = [String]()
    var counts = [Int]()
    var options = [String:String]()
      var set = 0
   
    //MARK: IBOutlets
    
    @IBOutlet weak var titleTextView: KMPlaceholderTextView!
    @IBOutlet weak var space: NSLayoutConstraint!
    @IBOutlet weak var adding: UIButton!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var optionOne: UITextField!
    @IBOutlet weak var optionTwo: UITextField!

    // Enables delegates for textFields/textView
    override func viewDidLoad() {
        super.viewDidLoad()
        optionOne.tag = 1
        optionTwo.tag = 2
        optionOne.delegate = self as! UITextFieldDelegate
        optionTwo.delegate = self as! UITextFieldDelegate
        titleTextView.delegate = self as! UITextViewDelegate
        
    }
    
    // Adds another option and generates it on the page for the admin
    @IBAction func addOption(_ sender: Any) {
        let sampleTextField = UITextField(frame: CGRect(x: 20, y: 340+(78*set), width: 335, height: 30))
        sampleTextField.placeholder = ""
        sampleTextField.font = UIFont.systemFont(ofSize: 15)
        sampleTextField.borderStyle = UITextBorderStyle.roundedRect
        sampleTextField.autocorrectionType = UITextAutocorrectionType.no
        sampleTextField.keyboardType = UIKeyboardType.default
        sampleTextField.returnKeyType = UIReturnKeyType.done
        sampleTextField.clearButtonMode = UITextFieldViewMode.whileEditing;
        sampleTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        sampleTextField.delegate = self as UITextFieldDelegate
        sampleTextField.tag = set+3
        sampleTextField.spellCheckingType = .no
        sampleTextField.autocapitalizationType = .none
        sampleTextField.autocorrectionType = .no
        
        if (set%2 == 0) { // Alternates colors
            sampleTextField.backgroundColor = UIColor.init(red: 253/255, green: 185/255, blue: 39/255, alpha: 0.50)
        } else {
            sampleTextField.backgroundColor = UIColor.init(red: 0/255, green: 107/255, blue: 182/255, alpha: 0.50)

        }
        self.scroll.addSubview(sampleTextField)
        
        let label: UILabel = UILabel(frame: CGRect(x: 20, y: 292+(80*set), width: 320, height: 33))
        label.tag = set
        self.scroll.addSubview(label)
        label.text = "Option \(set+3)"
        label.font = .boldSystemFont(ofSize: 17)
        
        self.space.constant = CGFloat(60+(set+1)*80)
        set += 1
        if (set == 7){
            self.adding.isEnabled = false
            self.adding.alpha = 0.0
        }
        
    }
    
    // Upload the new poll to Firebase
    @IBAction func savePoll(_ sender: UIBarButtonItem) {
        let optionsValues = self.options.values
        if (self.titleTextView.text?.trimmingCharacters(in: .whitespaces).isEmpty)! == true {
            let alertController = UIAlertController(title: "Poll has no title", message:
                "Make sure you type in a title for your poll.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        
        } else {
            for value in optionsValues {
     ref.child("poll").child(StaticVariables.currentEventQR).child(self.titleTextView.text).child(value).child("count").setValue(["Counter": 0])
            }
        }
        
        self.load(qrvalue: StaticVariables.currentEventQR)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Limit the title character count to 72
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        return ((numberOfChars < 72) && !(newText.contains(".")) && !(newText.contains("#")) && !(newText.contains("$")) && !(newText.contains("[")) && !(newText.contains("]")))
    }

    // Limit the options character count to 71
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        
        if (newLength <= 71){
            if (textField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! == false {
                let when = DispatchTime.now() + 0.1
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.options["\(textField.tag)"] = textField.text
                }
            }
        }
        
        return ((newLength <= 71) && !(string.contains(".")) && !(string.contains("#")) && !(string.contains("$")) && !(string.contains("[")) && !(string.contains("]")))
    }
    
    // Utilize this to adjust the cell heights according to option quantities
    func loadCounts(qrvalue2: String) {
        for i in self.titles {
            self.ref.child("poll").child(qrvalue2).child(i).observe(.value) { (snapshot: FIRDataSnapshot!) in
                var counter = 0
                for item in snapshot.children {
                    counter += 1
                }
                self.counts.append(counter)
                AdminRowHeightCounter.sharedInstance.counters = self.counts
            }
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "adminHome")
        self.present(controller, animated: true, completion: nil)
    }

    
    func load(qrvalue: String){
        self.ref = FIRDatabase.database().reference()
        ref.child("poll").child(qrvalue).observe(.value) { (snapshot: FIRDataSnapshot!) in
            var titlesTemp = [String]()
            for item in snapshot.children {
                let childSnapshot = snapshot.childSnapshot(forPath: (item as AnyObject).key)
                let titleID = childSnapshot.key
                titlesTemp.append(titleID)
            }
            self.titles = titlesTemp
            self.loadCounts(qrvalue2: qrvalue)
        }
    }
    
}
