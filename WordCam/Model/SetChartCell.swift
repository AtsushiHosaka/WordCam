//
//  ChartTableViewCell.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/06/27.
//

import UIKit
import RealmSwift
import Charts

class SetChartCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundLabel.layer.cornerRadius = 30
        backgroundLabel.clipsToBounds = true
        
        setLineGraph()
    }
    
    @IBOutlet var backgroundLabel: UILabel!
    @IBOutlet weak var linechart: LineChartView!
    
    var data: List<SetAnsHistory>?
    
    //data == nilの場合について考えられていません！
    //https://teratail.com/questions/139531
    func setLineGraph(){
        
        var dates = [Date]()
        var rates = [Double]()
        for d in data! {
            dates.append(d.date)
            rates.append(d.rate)
        }
        
        var entry = [ChartDataEntry]()
            
        for i in 0 ..< data!.count {
            entry.append(ChartDataEntry(x: Double(i),y: rates[i]))
        }
        
        let dataset = LineChartDataSet(entries: entry,label: "Units Sold")
                    
        linechart.data = LineChartData(dataSet: dataset)
        linechart.chartDescription.text = "Item Sold Chart"
    }
    
}
