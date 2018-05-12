//
//  AdminLoginViewController.swift
//  FanLink
//
//  Created by Clifford Yin on 4/1/17.
//  Copyright © 2017 Clifford Yin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Whisper

/* Serves as a login for an admin of an event */
class AdminLoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var ref = FIRDatabase.database().reference()
    var titles = [String]()
    var counts = [Int]()
    var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FanLoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    override func dismissKeyboard() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Processes the admin's attempt to log in
    @IBAction func signIn(_ sender: UIButton) {
        FIRAuth.auth()?.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if error != nil{
                guard let navigationController = self.navigationController else { return }
                let message = Message(title: "Invalid credentials.", backgroundColor: .red)
                Whisper.show(whisper: message, to: navigationController, action: .show)
                print(error?.localizedDescription)
            } else {
                
            self.ref.child("admin").observeSingleEvent(of: .value, with: { (snapshot) in
                let user = FIRAuth.auth()?.currentUser
                var uid = ""
                var finalValue = ""
                let value = snapshot.value as? NSDictionary
                uid = (FIRAuth.auth()?.currentUser!.uid)!
                if (value?[uid] != nil) {
                    finalValue = value?[uid] as? String ?? ""
                    StaticVariables.currentEventQR = finalValue
                    print("Hi \(StaticVariables.currentEventQR)")
                    self.load(qrvalue: StaticVariables.currentEventQR)
                } else {
                    guard let navigationController = self.navigationController else { return }
                    let message = Message(title: "No code linked to account.", backgroundColor: .red)
                    Whisper.show(whisper: message, to: navigationController, action: .show)
                    }
                })
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
                self.counts.append(counter) // Adjusts height of cells
                AdminRowHeightCounter.sharedInstance.counters = self.counts
                AdminRowHeightCounter.sharedInstance.titles = self.titles
            }
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "adminHome")
        self.present(controller, animated: true, completion: nil)
    }
    
    
    override var inputAccessoryView: UIView? {
        toolbar = UIToolbar()
        toolbar.isTranslucent = false
        toolbar.tintColor = UIColor.black
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let postButton = UIBarButtonItem(title: "Enter Credentials", style: .plain, target: self, action: #selector(FanLoginViewController.submitCode))
        postButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 16.0)!, NSForegroundColorAttributeName: UIColor.gray], for: UIControlState())
        postButton.isEnabled = false
        toolbar.items = [space, postButton]
        toolbar.sizeToFit()
        return toolbar
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
