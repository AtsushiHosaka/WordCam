//
//  ColorModel.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/05/30.
//

import UIKit

struct Color {
    //gray(default), red, blue, yellow
    let colorValues: [[CGFloat]] = [[163.0, 163.0, 163.0], [255.0, 154.0, 154.0], [98.0, 199.0, 217.0], [247.0, 226.0, 65.0], [28.0, 40.0, 103.0],
                                    [13, 115, 182], [82, 133, 195], [148, 183, 226], [71, 102, 189], [79, 85, 159], [96, 132, 161], [243, 162, 145], [197, 113, 128], [234, 210, 162], [202, 169, 205], [209, 123, 213], [241, 157, 104], [245, 13, 68], [249, 79, 76], [251, 158, 62], [31, 124, 182]]
    
    func colorCG(num: Int) -> CGColor {
        let color = colorValues[num]
        return CGColor(red: color[0]/255, green: color[1]/255, blue: color[2]/255, alpha: 1.0)
    }
    
    func colorUI(num: Int) -> UIColor {
        let color = colorValues[num]
        return UIColor(red: color[0]/255, green: color[1]/255, blue: color[2]/255, alpha: 1.0)
    }
}
