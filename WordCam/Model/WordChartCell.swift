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
    
    var data: List<WordAnsHistory>?
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet var gradientView: GradientView!
    
    public override func setup() {
        super.setup()
        self.height = ({return 250})
    }
    
    public override func update() {
        super.update()
        showChart()
        
    }
    
    func showChart() {
        
        var dates = [Date]()
        var rates = [Double]()
        
        for d in data! {
            dates.append(d.date)
            if d.rate == 0 {
                rates.append(1)
            }else {
                rates.append(d.rate * 100)
            }
        }
        
        var entries = [BarChartDataEntry]()
        
        for i in 0..<min(rates.count, 8) {
            entries.append(BarChartDataEntry(x: Double(min(rates.count, 8) - i - 1), y: rates[rates.count - i - 1]))
        }
        
        //let color = UIColor(white: 50/255, alpha: 1.0)
        let color = Color.shared.mainColor
        let dataSet = BarChartDataSet(entries: entries)
        dataSet.drawValuesEnabled = false
        dataSet.colors = [color]
        
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
        barChart.xAxis.gridColor = color
        //barChart.xAxis.labelTextColor = UIColor.white
        
        barChart.leftAxis.drawAxisLineEnabled = false
        barChart.leftAxis.axisMinimum = 0.0
        barChart.leftAxis.axisMaximum = 100.0
        barChart.leftAxis.gridLineDashLengths = [6]
        barChart.leftAxis.gridColor = color
        barChart.leftAxis.axisLineColor = color
        barChart.leftAxis.labelTextColor = color
        
        barChart.rightAxis.enabled = false
        
        let data = BarChartData(dataSet: dataSet)
        data.barWidth = 0.5
        barChart.data = data
    }
}

public final class WordChartRow: Row<WordChartCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<WordChartCell>(nibName: "WordChartCell")
    }
}
