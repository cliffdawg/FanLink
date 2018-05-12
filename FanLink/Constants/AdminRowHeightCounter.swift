//  AdminRowHeightCounter.swift
//  FanLink
//
//  Created by Clifford Yin on 4/1/17.
//  Copyright © 2017 Clifford Yin. All rights reserved.
//

import Foundation
import Firebase

/* A static structure on the admin side that stores the quantities of options in each poll. Thus, it assists in asjusting the height of each poll cell to fit those options. */
class AdminRowHeightCounter {
    var counters = [Int]()
    var titles = [String]()
    var setupPercents = [String:[ String: String]]()
    
    static let sharedInstance = AdminRowHeightCounter()
    
    fileprivate init () {
    }

}

