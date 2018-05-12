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
import Charts

protocol RefreshViewControllerDelegate {
    func refresh(_ add: Int)
}

/* Code that implements and displays a poll and its results */
class PollCell: UITableViewCell {
    
    // MARK: Properties
    
    var ref = FIRDatabase.database().reference()
    var loaded = false
    @IBOutlet weak var pollTitle: UILabel!
    var load2 = false
    var loadedChart = false
    var row = 0
    var options = [String]()
    var counts = [Int]()
    var delegate: RefreshViewControllerDelegate!
    var protect = [Int]()
    
    @IBOutlet weak var chartHeight: NSLayoutConstraint!
    
    @IBOutlet weak var chartTop: NSLayoutConstraint!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.pollTitle.tag = 999
        self.chart.tag = 998
        protect = [999, 998] // Prevent these tagged objects from being removed later
        
        self.contentView.sendSubview(toBack: chart) // Push the chart back
        self.chart.alpha = 0.0
        
        // Remove everything except protected objects
            for object in self.contentView.subviews {
                if (protect.contains(object.tag) == false) {
                    object.removeFromSuperview()
                }
            }
        self.loadedChart = true
    }
    
    
    func removingViews() {
        self.pollTitle.tag = 999
        self.chart.tag = 998
        
        protect.append(998)
        protect.append(999)
        
        self.contentView.sendSubview(toBack: chart)
        self.chart.alpha = 0.0
            
            for object in self.contentView.subviews {
                if (protect.contains(object.tag) == false) {
                    object.removeFromSuperview()
                }
            }
    }
    
    // When the first option is pressed, increment it on Firebase and animate the chart
    @objc func optionOne(_ sender: UIButton) {
        
        self.loaded = true
        RowHeightCounter.pressedRows.append(self.row)
        delegate.refresh(self.row)
        
        self.options.reverse()
        self.counts.reverse()
        self.setChart(dataPoints: self.options, values: self.counts)
    ref.child("poll").child(StaticVariables.currentEventQR).child(pollTitle.text!).child((sender.titleLabel?.text!)!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let item = snapshot.children.allObjects[0]
            let childSnapshot = snapshot.childSnapshot(forPath: (item as AnyObject).key)
            let responseID = childSnapshot.key
            let reponseValue = childSnapshot.value as? NSDictionary
            var response = reponseValue?["Counter"] as! Int
        
            response += 1 // Increment votes
        self.ref.child("poll").child(StaticVariables.currentEventQR).child(self.pollTitle.text!).child((sender.titleLabel?.text!)!).child("count").setValue(["Counter": response])
        
        })
       
        self.contentView.bringSubview(toFront: self.chart) // Animate and bring to front
    }
    

    func runRemove(completion:(_ success: Bool) -> Void) {
            completion(true)
    }
    
    
    func configure(polltitled: String, num: Int) {
        self.pollTitle.text = polltitled
        self.row = num
        
        self.runRemove() { (success) -> Void in
            if success {
                self.loadChart()
            }
            else {
                    }
            }
    }
    
    func configure2 (polltitle: String, number: Int) {
        self.pollTitle.text = polltitle
        self.row = number
        self.loadChart2()
        var height = 0
        if ((self.pollTitle.text?.characters.count)! > 37){
            height = 22
        }
        
        // Adjusts chart height in relation to how many options there are
        self.chartTop.constant = CGFloat(64)
        self.chartHeight.constant = CGFloat((RowHeightCounter.sharedInstance.counters[row])*62+39)
        
    }
    
    @IBOutlet weak var chart: HorizontalBarChartView!
    
    // Set the data of the options in the chart
    func setChart(dataPoints: [String], values: [Int]) {
        
        chart.chartDescription?.text = ""
        chart.noDataText = ""
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(counts[i]))
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Votes")
        let chartData = BarChartData(dataSet: chartDataSet)
        chartDataSet.colors = [UIColor(red: 119/255, green: 208/255, blue: 237/255, alpha: 1)]
        chart.data = chartData
        chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: options)
        chart.xAxis.granularity = 1
        self.chart.alpha = 1.0
        chart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
    }
    
    
    // Pull options from Firebase
    func loadChart2() {
        ref.child("poll").child(StaticVariables.currentEventQR).child(self.pollTitle.text!).observe(.value) { (snapshot: FIRDataSnapshot!) in
            
            self.counts.removeAll()
            self.options.removeAll()

            for item in snapshot.children {
                let childSnapshot = snapshot.childSnapshot(forPath: (item as AnyObject).key)
                let option = childSnapshot.key
                self.options.append(option)
                
            }
            self.loadCounts2()
            self.load2 = true
        }
    }

    func setChart2(dataPoints: [String], values: [Int]) {
        
        self.chartHeight.constant = CGFloat((RowHeightCounter.sharedInstance.counters[row])*62+39)
        chart.chartDescription?.text = ""
        chart.noDataText = ""
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(counts[i]))
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Votes")
        let chartData = BarChartData(dataSet: chartDataSet)
        
        chartDataSet.colors = [UIColor(red: 119/255, green: 208/255, blue: 237/255, alpha: 1)]
        chart.data = chartData
        chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: options)
        chart.xAxis.wordWrapEnabled = true
        chart.xAxis.granularity = 1
        self.chart.alpha = 1.0
        chart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
        
        self.bringSubview(toFront: self.chart)
    }
    
    
    func loadChart(){
    
        ref.child("poll").child(StaticVariables.currentEventQR).child(self.pollTitle.text!).observe(.value) { (snapshot: FIRDataSnapshot!) in
            
            self.counts.removeAll()
            self.options.removeAll()
            for item in snapshot.children {
                let childSnapshot = snapshot.childSnapshot(forPath: (item as AnyObject).key)
                let option = childSnapshot.key
                self.options.append(option)
            }
            
            self.loadCounts()
            self.createButtons()
            self.sendSubview(toBack: self.chart)
            self.chart.alpha = 0.0
            self.load2 = true
        }
    }
    
    // Generate the buttons to represent the options
    func createButtons() {
        var i = 1
        var height = 0
        if ((self.pollTitle.text?.characters.count)! > 37) {
            height = 22
        }
        for option in self.options{
            let btn: UIButton = UIButton(frame: CGRect(x: Int(self.contentView.frame.size.width - 320)/2, y: 59+60*(i-1)+height, width: 320, height: 33))
            if ((i)%2 == 1) { // Alternate blue and gold colors
                btn.backgroundColor = UIColor.init(red: 253/255, green: 185/255, blue: 39/255, alpha: 1.0)
            } else {
                btn.backgroundColor = UIColor.init(red: 0/255, green: 107/255, blue: 182/255, alpha: 1.0)
            }
            
            btn.addTarget(self, action: #selector(PollCell.optionOne(_:)), for: .touchUpInside)
            btn.tag = i
            protect.append(btn.tag) // Make sure button isn't removed unexpectedly
            self.contentView.addSubview(btn)
            btn.setTitle(option, for: .normal)
            btn.titleLabel?.adjustsFontSizeToFitWidth = true
            i += 1
        }
        self.removingViews()
    }
    
    // Load the votes that each option has
    func loadCounts() {
        for i in self.options {
    self.ref.child("poll").child(StaticVariables.currentEventQR).child(self.pollTitle.text!).child(i).observe(.value) { (snapshot: FIRDataSnapshot!) in
                
                for item in snapshot.children {
                        let childSnapshot = snapshot.childSnapshot(forPath: (item as AnyObject).key)
                        let countsValue = childSnapshot.value as? NSDictionary
                        let count = countsValue?["Counter"] as! Int
                        self.counts.append(count)
                    }
                }
            }
        }
    
    
    func loadCounts2() {
        var counter = 0
        for i in self.options {
            self.ref.child("poll").child(StaticVariables.currentEventQR).child(self.pollTitle.text!).child(i).observe(.value) { (snapshot: FIRDataSnapshot!) in
                
                for item in snapshot.children {
                    
                    let childSnapshot = snapshot.childSnapshot(forPath: (item as AnyObject).key)
                    let countsValue = childSnapshot.value as? NSDictionary
                    let count = countsValue?["Counter"] as! Int
                    self.counts.append(count)
                    counter += 1
                    if (self.options.count == counter) {
                        self.setChart2(dataPoints: self.options, values: self.counts)
                    }
                }
            }
        }
    }
    
}

