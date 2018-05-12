//
//  PollCell.swift
//  FanLink
//
//  Created by Clifford Yin on 4/1/17.
//  Copyright © 2017 Clifford Yin. All rights reserved.
//

import Foundation
import UIKit
import Firebase

/* Code that constitutes the cell that the admin views from the organizer side regarding polls */
class SeePollCell: UITableViewCell {
    
    var ref = FIRDatabase.database().reference()
    var loaded = false
    var percentages = [Double]()
    var load = true
    @IBOutlet weak var pollTitle: UILabel!
    
    var options = [String]()
    var counts = [Int]()
    
    // Clear out old leftover labels
    override func prepareForReuse() {
        self.counts.removeAll()
        self.options.removeAll()
        self.percentages.removeAll()
    }
    
    func configure(polltitled :String){
        self.pollTitle.tag = 999
        for object in self.contentView.subviews {
            if (object.tag != 999) {
                object.removeFromSuperview()
            
            }
        }
        self.counts.removeAll()
        self.options.removeAll()
        self.percentages.removeAll()
        self.pollTitle.text = polltitled
        loadChart()
        self.load = false
    }
    
    func loadChart(){
            var counter = 0
            ref.child("poll").child(StaticVariables.currentEventQR).child(self.pollTitle.text!).observe(.value) { (snapshot: FIRDataSnapshot!) in
            
            for item in snapshot.children {
                let childSnapshot = snapshot.childSnapshot(forPath: (item as AnyObject).key)
                let option = childSnapshot.key
                self.options.append(option)
                counter += 1
                if (counter == Int(snapshot.childrenCount)) {
                    self.createStats()
                    self.loadCounts()
                }
            }

            // Tester functions
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when) {
            }

            let when2 = DispatchTime.now() + 4
            DispatchQueue.main.asyncAfter(deadline: when2) {
            }
        }
    }
    
    // Generates options for the admin to see
    func createStats() {
        var i = 0
        var height = 0
        
        for option in self.options{
            var height = 0
            if ((self.pollTitle.text?.characters.count)! > 37){
                height = 22
            }
            let label: UILabel = UILabel(frame: CGRect(x: 40, y:  69+60*(i)-25+height, width: 200, height: 50))
            if (i%2 == 1){
                label.textColor = UIColor.init(red: 253/255, green: 185/255, blue: 39/255, alpha: 1.0)
            } else {
                label.textColor = UIColor.init(red: 0/255, green: 107/255, blue: 182/255, alpha: 1.0)
            }
            
            label.tag = i
            self.contentView.addSubview(label)
            label.text = option
            label.font = label.font.withSize(22.0)
            label.numberOfLines = 2
            label.minimumScaleFactor = 0.5
            label.adjustsFontSizeToFitWidth = true
            label.textAlignment = .center
            i += 1
        }
    }
    
    // Generated the percentages of votes for each option
    func loadPercentages() {
        var totalSum = 0
        for count in self.counts{
            totalSum += count
        }
        for count in self.counts{
            var percent = Double(count)/Double(totalSum)
            if (count == 0 && totalSum != 0){
                percent = 0
            }
            if (count == 0 && totalSum == 0){
                percent = 0
            }
            self.percentages.append(percent*100)
        }
        self.loadStats()
    }
    
    func loadStats() {
        var i = 0
        var height = 0
        if ((self.pollTitle.text?.characters.count)! > 37){
            height = 22
        }
        for count in self.percentages{
            let label: UILabel = UILabel(frame: CGRect(x: 240, y: 69+60*(i)+height-25, width: 100, height: 50))
            
            if (i%2 == 1){
                label.textColor = UIColor.init(red: 253/255, green: 185/255, blue: 39/255, alpha: 1.0)
            } else {
                label.textColor = UIColor.init(red: 0/255, green: 107/255, blue: 182/255, alpha: 1.0)
            }

            label.tag = i
            self.contentView.addSubview(label)
            let count2 = round(100*count)/100
            label.text = "\(count2)" + "%"
            label.font = label.font.withSize(22.0)
            label.textAlignment = .center
            let label2: UILabel = UILabel(frame: CGRect(x: Int(self.contentView.frame.size.width - 250)/2, y: 69+60*(i)+height+25, width: 250, height: 2))
            label2.backgroundColor = UIColor(red:179/255, green:196/255, blue:201/255, alpha: 1.0)
            label2.layer.cornerRadius = 1.0
            self.contentView.addSubview(label2)
            i += 1
        }
    }
    
    
    func loadCounts() {
        for i in self.options {
            self.ref.child("poll").child(StaticVariables.currentEventQR).child(self.pollTitle.text!).child(i).observe(.value) { (snapshot: FIRDataSnapshot!) in
                
                for item in snapshot.children {
                    
                    let childSnapshot = snapshot.childSnapshot(forPath: (item as AnyObject).key)
                    let countsValue = childSnapshot.value as? NSDictionary
                    let count = countsValue?["Counter"] as! Int
                    self.counts.append(count)
                    if (self.options.count == self.counts.count) {
                        self.loadPercentages()
                    }
                }
            }
        }
    }
}

