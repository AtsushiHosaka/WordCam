//
//  ColorModel.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/05/30.
//

import UIKit

struct MyColor {
    
    let startColors: [[CGFloat]] = [[86, 81, 214], [0, 194, 229], [150, 148, 148], [251, 153, 99], [255, 139, 139], [16, 201, 130], [185, 85, 219], [229, 196, 126]]
    
    let endColors: [[CGFloat]] = [[52, 49, 161], [0, 154, 219], [103, 103, 103], [242, 103, 61], [240, 96, 96], [0, 142, 67], [146, 34, 184], [176, 142, 39]]
    
    let mainColor = UIColor(red: 28/255, green: 40/255, blue: 103/255, alpha: 1.0)
    let backgroundColor = UIColor(white: 249/255, alpha: 1.0)
    
    static let shared = MyColor()
    
    func colorCG(num: Int, type: Int) -> CGColor {
        if type == 0 {
            let color = startColors[num]
            return CGColor(red: color[0]/255, green: color[1]/255, blue: color[2]/255, alpha: 1.0)
        }else {
            let color = endColors[num]
            return CGColor(red: color[0]/255, green: color[1]/255, blue: color[2]/255, alpha: 1.0)
        }
    }
    
    func colorUI(num: Int, type: Int) -> UIColor {
        if type == 0 {
            let color = startColors[num]
            return UIColor(red: color[0]/255, green: color[1]/255, blue: color[2]/255, alpha: 1.0)
        }else {
            let color = endColors[num]
            return UIColor(red: color[0]/255, green: color[1]/255, blue: color[2]/255, alpha: 1.0)
        }
    }
}
