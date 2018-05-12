//
//  RaffleViewController.swift
//  FanLink
//
//  Created by Clifford Yin on 4/1/17.
//  Copyright © 2017 Clifford Yin. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase

/* Code to manage the participant side of the raffle page */
class RaffleViewController: UIViewController {
    
    var eventCode = StaticVariables.currentEventQR
    var ref = FIRDatabase.database().reference()
    
    @IBOutlet weak var winner: UILabel!
    @IBOutlet weak var anonID: UILabel!
    @IBOutlet weak var eventStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signIn() { (success) -> Void in
            if success {
                    self.signIn2()
            }
            else {
            }
        }
    }
    
    func signIn(completion: @escaping (_ success: Bool) -> Void) {
        if (UserDefaults.standard.value(forKey: "raffle") == nil) { // Stores value associated with raffle into phone locally
                let reffer = ref.childByAutoId()
                let refd = reffer.key
                UserDefaults.standard.set(refd, forKey: "raffle")
                completion(true)
        } else {
            completion(true)
        }
    }
    
    
    func signIn2() {
        
            let idid = UIDevice.current.identifierForVendor!.uuidString
            let trunk = UserDefaults.standard.string(forKey: "raffle")
            self.anonID.text = self.truncate(x: trunk!)
            self.ref.child("raffle").child(self.eventCode).child(idid).setValue(self.anonID.text!)
        
            // Extracts the winner of the raffle
            self.ref.child("raffle").child(self.eventCode).child("winner").observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value
                    self.eventStatusLabel.text = value as? String // Set raffle winner
            })
        
        ref.child("raffle").child(self.eventCode).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let raffleChosen = value?["winner"] as? String ?? ""
            if (raffleChosen != "placeHolder") {
            if (raffleChosen != "TBD") {
                if(raffleChosen == self.anonID.text) {
                    self.winner.text = "Congrats! You won the raffle!"
                } else {
                    if(raffleChosen != nil) {
                        self.winner.text = "Winner: " + raffleChosen
                    }
                    else {
                        self.winner.text = "Winner not chosen yet."
                    }
                }
            }
            } else {
                self.winner.text = "Winner not chosen yet."
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func truncate(x: String) -> String {
        var returnString = ""
        var chars = Array(x.characters)
        for i in 1...7 {
            returnString.append(chars[i])
        }
        return returnString
    }
}
