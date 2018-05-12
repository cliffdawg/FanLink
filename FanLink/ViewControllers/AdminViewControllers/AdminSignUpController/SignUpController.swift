//
//  SignUpController.swift
//  FanLink
//
//  Created by Clifford Yin on 5/20/17.
//  Copyright © 2017 Clifford Yin. All rights reserved.
//

import Firebase
import UIKit
import Whisper

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

/* Allows an admin to register a new event */
class SignUpController: UIViewController {
    
    var ref = FIRDatabase.database().reference()
    var login = false
    var titles = [String]()
    var counts = [Int]()
    
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var passwordConfirmText: UITextField!
    @IBOutlet weak var qrCode: UITextField!
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        if (self.qrCode.text != "") {
        if (self.passwordText.text == self.passwordConfirmText.text) {
        FIRAuth.auth()?.createUser(withEmail: usernameText.text!, password: passwordText.text!) { (user, error) in
            
            // If user ID is valid
            if user?.uid != nil  {
               
                StaticVariables.currentEventQR = self.qrCode.text!
                self.addUserInfoToDatabase(ided: (user?.uid)!, qr: self.qrCode.text!)

                
            } else {
        
                guard let navigationController = self.navigationController else { return }
                let message = Message(title: "Invalid. Make sure you are registering with email.", backgroundColor: .red)
                Whisper.show(whisper: message, to: navigationController, action: .show)
                }
            }
        } else {
            guard let navigationController = self.navigationController else { return }
            let message = Message(title: "Invalid. Make sure passwords match.", backgroundColor: .red)
            Whisper.show(whisper: message, to: navigationController, action: .show)
        }
            } else {
                guard let navigationController = self.navigationController else { return }
                let message = Message(title: "Please enter a code.", backgroundColor: .red)
                Whisper.show(whisper: message, to: navigationController, action: .show)
            }
        }
    
    // Adds admin values to Firebase
    func addUserInfoToDatabase(ided: String, qr: String) {

        self.ref.child("events").child(ided).setValue(["qrCode":qr])
        self.load(qrvalue: qr)
        self.ref.child("admin").child(ided).setValue(StaticVariables.currentEventQR)
    self.ref.child("raffle").child(StaticVariables.currentEventQR).child("placeholder").setValue("placeHolder")
        }

        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // Check for internet connection
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK")
        } else {
            print("Internet connection FAILED")
            let alertController = UIAlertController(title: "No Internet Connection", message:
                "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
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
        let controller = storyboard.instantiateViewController(withIdentifier: "adminHome")
        self.present(controller, animated: true, completion: nil)
    }
    
    
    func load(qrvalue: String) {
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
