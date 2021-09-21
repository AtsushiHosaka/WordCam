//
//  WordChartCell.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/08/02.
//

import UIKit
import RealmSwift
import Eureka
import Charts

public class WordChartCell: Cell<Bool>, CellType {
    
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var dayLabel: UILabel!
    
    var wordData = [WordAnsHistory]() {
        didSet {
            showChart()
        }
    }
    
    public override func setup() {
        super.setup()
        self.height = ({return 250})
    }
    
    func showChart() {
        var data = wordData
        
        var dates = [Double]()
        var rates = [Double]()
        
        data.reverse()
        
        while dates.count <= 8 && !data.isEmpty {
            if !dates.contains(dateToValue(date: data[0].date)) {
                dates.append(dateToValue(date: data[0].date))
                if data[0].rate == 0 {
                    rates.append(1)
                }else {
                    rates.append(data[0].rate * 100)
                }
            }else {
                let rate = (data[0].rate*100 + rates[rates.count - 1]) / 2
                rates[rates.count - 1] = rate
            }
            data.remove(at: 0)
        }
        
        dates.reverse()
        rates.reverse()
        
        var entries = [BarChartDataEntry]()
        
        for i in 0..<rates.count {
            entries.append(BarChartDataEntry(x: Double(i), y: rates[i]))
        }
        
        let color = MyColor.shared.mainColor
        let dataSet = BarChartDataSet(entries: entries)
        dataSet.drawValuesEnabled = false
        dataSet.colors = [color]
        
        barChart.legend.enabled = false
        barChart.highlightPerTapEnabled = false
        barChart.pinchZoomEnabled = false
        barChart.doubleTapToZoomEnabled = false
        
        barChart.xAxis.valueFormatter = ChartFormatter(dates: dates)
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.xAxis.drawAxisLineEnabled = false
        barChart.xAxis.labelPosition = .bottom
        barChart.xAxis.gridColor = color
        barChart.xAxis.labelTextColor = color
        
        if entries.count == 1 {
            barChart.xAxis.drawLabelsEnabled = false
            dayLabel.isHidden = false
            dayLabel.text = dateValueToString(value: dates[0])
        }else {
            barChart.xAxis.drawLabelsEnabled = true
            barChart.xAxis.labelCount = entries.count
            dayLabel.isHidden = true
        }
        
        barChart.leftAxis.drawAxisLineEnabled = false
        barChart.leftAxis.axisMinimum = 0.0
        barChart.leftAxis.axisMaximum = 100.0
        barChart.leftAxis.gridLineDashLengths = [6]
        barChart.leftAxis.gridColor = color
        barChart.leftAxis.axisLineColor = color
        barChart.leftAxis.labelTextColor = color
        
        barChart.rightAxis.enabled = false
        
        let barChartData = BarChartData(dataSet: dataSet)
        barChartData.barWidth = 0.5
        barChart.data = barChartData
    }
    
    func dateToValue(date: Date) -> Double {
        return Double(date.month) * 100 + Double(date.day)
    }
    
    func dateValueToString(value: Double) -> String {
        String(Int(floor(value / 100))) + "/" + String(Int(value) % 100)
    }
}

public final class WordChartRow: Row<WordChartCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<WordChartCell>(nibName: "WordChartCell")
    }
}
