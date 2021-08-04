//
//  WordTitleCell.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/07/31.
//

import UIKit
import Eureka

public class WordTitleCell: Cell<Bool>, CellType {
    @IBOutlet var titleLabel: UILabel!
    
    public override func setup() {
        super.setup()
    }
    
    public override func update() {
        super.update()
        
    }
}

public final class WordTitleRow: Row<WordTitleCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<WordTitleCell>(nibName: "WordTitleCell")
    }
}
