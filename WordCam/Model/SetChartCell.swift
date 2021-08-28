//
//  ChartTableViewCell.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/06/27.
//

import UIKit
import RealmSwift
import Charts
import SwiftDate

class SetChartCell: UITableViewCell {
    
    @IBOutlet var alertLabel: UILabel!
    @IBOutlet var backgroundLabel: UILabel!
    @IBOutlet weak var barChart: BarChartView!
    
    var data: List<SetAnsHistory>? {
        didSet {
            showChart()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundLabel.layer.cornerRadius = 30
        backgroundLabel.clipsToBounds = true
    }
    
    func showChart() {
        if data == nil {
            alertLabel.isHidden = false
            barChart.isHidden = true
        }else {
            alertLabel.isHidden = true
            barChart.isHidden = false
            
            var dates = [Double]()
            var rates = [Double]()
            
            //dateを4桁のdoubleで表す。mmdd.0
            for d in data! {
                dates.append(Double(d.date.month * 100 + d.date.day))
                if d.rate == 0 {
                    rates.append(1)
                }else {
                    rates.append(d.rate * 100)
                }
            }
            
            //let entries = rates.enumerated().map { BarChartDataEntry(x: Double($0.offset), y: Double($0.element)) }
            var entries = [BarChartDataEntry]()
            
            for i in 0..<min(rates.count, 8) {
                entries.append(BarChartDataEntry(x: Double(min(rates.count, 8) - i - 1), y: rates[rates.count - i - 1]))
            }
            
            let dataSet = BarChartDataSet(entries: entries)
            dataSet.drawValuesEnabled = false
            dataSet.colors = [UIColor.white]
            
            barChart.legend.enabled = false
            barChart.highlightPerTapEnabled = false
            barChart.pinchZoomEnabled = false
            barChart.doubleTapToZoomEnabled = false
            
            //barChart.xAxis.valueFormatter = ChartFormatter()
            barChart.xAxis.drawLabelsEnabled = false
            barChart.xAxis.drawGridLinesEnabled = false
            barChart.xAxis.drawAxisLineEnabled = false
            barChart.xAxis.labelCount = 5
            //barChart.xAxis.labelPosition = .bottom
            barChart.xAxis.gridColor = UIColor.white
            //barChart.xAxis.labelTextColor = UIColor.white
            
            barChart.leftAxis.drawAxisLineEnabled = false
            barChart.leftAxis.axisMinimum = 0.0
            barChart.leftAxis.axisMaximum = 100.0
            barChart.leftAxis.gridLineDashLengths = [6]
            barChart.leftAxis.gridColor = UIColor.white
            barChart.leftAxis.axisLineColor = UIColor.white
            barChart.leftAxis.labelTextColor = UIColor.white
            
            barChart.rightAxis.enabled = false
            
            let data = BarChartData(dataSet: dataSet)
            data.barWidth = 0.5
            barChart.data = data
        }
    }
    
    class ChartFormatter: IndexAxisValueFormatter {
        let date = Date()
        override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return String(Int(value/100)) + "/" + String(Int(value) % 100)
        }
    }
    
}
