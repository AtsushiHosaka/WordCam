//
//  ChartTableViewCell.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/06/27.
//

import UIKit
import Charts

class ChartTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundLabel.layer.cornerRadius = 30
        // Initialization code
        setLineGraph()
    }
    
    @IBOutlet var backgroundLabel: UILabel!
    @IBOutlet weak var linechart: LineChartView!
        
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
    let unitsSold = [10.0, 4.0, 6.0, 3.0, 12.0, 16.0]
        
    func setLineGraph(){
        var entry = [ChartDataEntry]()
            
        for (i,d) in unitsSold.enumerated(){
            entry.append(ChartDataEntry(x: Double(i),y: d))
        }
        
        let dataset = LineChartDataSet(entries: entry,label: "Units Sold")
                    
        linechart.data = LineChartData(dataSet: dataset)
        linechart.chartDescription.text = "Item Sold Chart"
    }
    
}
