//
//  MeaningCell.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/08/30.
//

import UIKit
import Eureka

public class MeaningCell: Cell<Bool>, CellType {
    //0: 名詞, 1: 動詞, 2: 形容詞, 3: 副詞, 4: 助動詞, 5: 代名詞, 6: 前置詞, 7: 冠詞, 8: 接続詞
    let data = ["名詞", "動詞", "形容詞", "副詞", "助動詞", "代名詞", "前置詞", "冠詞", "接続詞"]
    var pickerView = UIPickerView()
    var selectedNum: Int?
    @IBOutlet var meaningTextField: UITextField!
    @IBOutlet var typeTextField: UITextField!
    
    var meaning = Meaning() {
        didSet {
            meaningTextField.text = meaning.meaning
            selectedNum = meaning.type
            let str = data[meaning.type]
            typeTextField.text = String(str[str.startIndex])
        }
    }

    public override func setup() {
        super.setup()
        self.height = ({return 44})
        
        setupTextField()
        createPickerView()
    }
    
    func setupTextField() {
        meaningTextField.text = ""
        meaningTextField.placeholder = "意味を入力してください"
        typeTextField.text = "名"
    }
    
    func createPickerView() {
        pickerView.delegate = self
        typeTextField.inputView = pickerView
        
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.layer.frame.width, height: 44)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.donePicker))
        toolbar.setItems([doneButtonItem], animated: true)
        typeTextField.inputAccessoryView = toolbar
    }
    
    @objc func donePicker() {
        typeTextField.endEditing(true)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        typeTextField.endEditing(true)
    }
}

extension MeaningCell: UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row]
    }
    
}

extension MeaningCell: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        typeTextField.text = String(data[row][data[row].startIndex])
        selectedNum = row
    }
}


public final class MeaningRow: Row<MeaningCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<MeaningCell>(nibName: "MeaningCell")
    }
}
