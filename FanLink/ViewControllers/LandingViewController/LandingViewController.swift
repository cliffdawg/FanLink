//
//  LandingViewController.swift
//  FanLink
//
//  Created by Clifford Yin on 4/2/17.
//  Copyright © 2017 Clifford Yin. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework
import Firebase

class LandingViewController: UIViewController {
    @IBOutlet weak var coachButton: UIButton!
    
    override func viewDidLoad() {
        coachButton.layer.borderWidth = 1
        coachButton.layer.borderColor = UIColor.init(hexString: "15A7E6").cgColor
        
    }
    
}
