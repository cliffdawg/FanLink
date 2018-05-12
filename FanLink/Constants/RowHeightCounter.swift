//  RowHeightCounter.swift
//  FanLink
//
//  Created by Clifford Yin on 4/1/17.
//  Copyright © 2017 Clifford Yin. All rights reserved.
//

import Foundation
import Firebase

/* A static structure on the participant side that stores the quantities of options in each poll. Thus, it assists in asjusting the height of each poll cell to fit those options. */
class RowHeightCounter {
    var counters = [Int]()
    
    static let sharedInstance = RowHeightCounter()
    
    fileprivate init () {
    }
    
    static var pressedRows = [Int]()
}

