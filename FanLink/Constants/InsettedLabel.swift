//
//  InsettedLabel.swift
//  FanLink
//
//  Created by Clifford Yin on 8/22/17.
//  Copyright © 2017 Clifford Yin. All rights reserved.
//

import UIKit
import Foundation

class InsetLabel: UILabel {
    let topInset = CGFloat(3)
    let bottomInset = CGFloat(3)
    let leftInset = CGFloat(15)
    let rightInset = CGFloat(15)
    
    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        self.layer.cornerRadius = 10.0
        self.layer.borderColor = UIColor(red: 242/255, green: 215/255, blue: 63/255, alpha: 1.0).cgColor
        self.layer.borderWidth = 3.0
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override public var intrinsicContentSize: CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += topInset + bottomInset
        intrinsicSuperViewContentSize.width += leftInset + rightInset
        

        return intrinsicSuperViewContentSize
    }
}
