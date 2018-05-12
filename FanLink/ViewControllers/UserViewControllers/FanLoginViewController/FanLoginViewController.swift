//
//  LoginViewController.swift
//  FanLink
//
//  Created by Clifford Yin on 4/1/17.
//  Copyright © 2017 Clifford Yin. All rights reserved.
//

import Foundation
import UIKit
import Whisper
import Firebase

/* Allows a fan to link to an event with a unique code */
class FanLoginViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var codeTextField: UITextField!
   
    var toolbar: UIToolbar!
    var ref = Firebase.FIRDatabase.database().reference()
    var titles = [String]()
    var counts = [Int]()
    let user = FIRAuth.auth()?.currentUser
    
    override func viewDidLoad() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FanLoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func dismissKeyboard() {
        view.endEditing(true)
    }

    override var inputAccessoryView: UIView? {
        toolbar = UIToolbar()
        toolbar.isTranslucent = false
        toolbar.tintColor = UIColor.black
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let postButton = UIBarButtonItem(title: "ENTER", style: .plain, target: self, action: #selector(FanLoginViewController.submitCode))
        postButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 16.0)!, NSForegroundColorAttributeName: UIColor.init(red: 22/255, green: 166/255, blue:228/255, alpha: 1.0)], for: UIControlState())
        toolbar.items = [space, postButton]
        toolbar.sizeToFit()
        return toolbar
    }
    
    // Processes the event code that the fan submitted
    func submitCode() {
        let code = codeTextField.text
        self.ref.child("events").observe(.value) { (snapshot: FIRDataSnapshot!) in
            
            var counter = false
            for item in snapshot.children {
                let childSnapshot = snapshot.childSnapshot(forPath: (item as AnyObject).key)
                let qrValue = childSnapshot.value as? NSDictionary
                let qr = qrValue?["qrCode"] as! String
                
                if(code == qr){
                    counter = true
                    StaticVariables.currentEventQR = code!
                    self.load(qrvalue: code!)
                        }
                    }
            if (counter == false) {
                DispatchQueue.main.async {
                guard let navigationController = self.navigationController else { return }
                let message = Message(title: "Your code is invalid.", backgroundColor: .red)
                Whisper.show(whisper: message, to: navigationController, action: .show)
                    }
                }
            }
        }
    

    func loadCounts(qrvalue2: String) {
        for i in self.titles {
            
            self.ref.child("poll").child(qrvalue2).child(i).observe(.value) { (snapshot: FIRDataSnapshot!) in
                var counter = 0
                for item in snapshot.children {
                    counter += 1
                }
                self.counts.append(counter)
                RowHeightCounter.sharedInstance.counters = self.counts
            }
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "fanHome")
        self.present(controller, animated: true, completion: nil)
        
    }
    
    // Loads titles of polls
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

