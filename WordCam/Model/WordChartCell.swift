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
    @IBOutlet weak var linechart: LineChartView!
    @IBOutlet var backgroundLabel: UILabel!
    
    public override func setup() {
        super.setup()
        self.height = ({return 140})
    }
    
    public override func update() {
        super.update()
        setLineGraph()
        
    }
    
    func setLineGraph() {
        
        var dates = [Date]()
        var rates = [Double]()
        for d in data! {
            dates.append(d.date)
            rates.append(d.rate)
        }
        var entry = [ChartDataEntry]()
        for(i,d) in rates.enumerated() {
            entry.append(ChartDataEntry(x: Double(i), y: d))
        }
        let dataset = LineChartDataSet(entries: entry, label: "%")
        
        linechart.data = LineChartData(dataSet: dataset)
        linechart.chartDescription.text = "正答率"
    }
}

public final class WordChartRow: Row<WordChartCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<WordChartCell>(nibName: "WordChartCell")
    }
}
