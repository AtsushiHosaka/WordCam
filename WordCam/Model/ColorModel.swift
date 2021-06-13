//
//  ColorModel.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/05/30.
//

import UIKit

struct Color {
    let red = CGColor(red: 1.0, green: 0, blue: 0, alpha: 1.0)
    let blue = CGColor(red: 0, green: 0, blue: 1.0, alpha: 1.0)
    
    func colorCode(code: String) -> CGColor {
        if code == "red" {
            return red
        }else {
            return blue
        }
    }
}
