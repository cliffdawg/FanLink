//
//  ManageRaffleViewController.swift
//  FanLink
//
//  Created by Clifford Yin on 4/1/17.
//  Copyright © 2017 Clifford Yin. All rights reserved.
//

import Foundation
import UIKit
import Firebase

/* Admin side of the raffle page, in which a random winner is selected */
class ManageRaffleViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chooseWinner(AnyObject.self)
    }
    
    var ref = FIRDatabase.database().reference()
    var eventCode = StaticVariables.currentEventQR

    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var numberOfEntrees: UILabel!
    
    @IBAction func chooseWinner(_ sender: Any) {
        var length = 0
        var randomIndex = 0
        var arr = [String]()
       
        ref = FIRDatabase.database().reference()
        self.ref.child("raffle").child(StaticVariables.currentEventQR).observeSingleEvent(of: .value, with: { (snapshot) in
        // Get user value
        let value = snapshot.value as? NSDictionary
       
        for (_, fvalue) in value! {
            print("arraying")
            if (fvalue as! String != "placeHolder") { // Make sure "placeholder" isn't used
            print(fvalue as! String)
            arr.append(fvalue as! String)
            }
        }
        
        length = arr.count
        self.numberOfEntrees.text = "\(length-1)"
        randomIndex = Int(arc4random_uniform(UInt32(length)))
        if (length != 0) {
            self.ref.child("raffle").child(StaticVariables.currentEventQR).child("winner").setValue(arr[randomIndex])
                self.winnerLabel.text = arr[randomIndex]
            } else {
                self.numberOfEntrees.text = "0"
            }
        }) {
            (error) in
        print(error.localizedDescription)
        }
    }
}
