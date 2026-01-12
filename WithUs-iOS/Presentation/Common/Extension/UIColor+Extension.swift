//
//  UIColor+Extension.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/10/26.
//

import UIKit

extension UIColor {
    /*waring label*/
    static let redWarning = UIColor(hex: "#E95053")
    
    /*disabled button*/
    static let disabled = UIColor(hex: "#D5D5D5")
    static let abled = UIColor(hex: "#212121")
    
    /*회색계열*/
    static let gray50 = UIColor(hex: "#F8F8F8")
    static let gray100 = UIColor(hex: "#F0F0F0")
    static let gray200 = UIColor(hex: "#E6E6E6")
    static let gray300 = UIColor(hex: "#D5D5D5")
    static let gray400 = UIColor(hex: "#D5D5D5")
    static let gray500 = UIColor(hex: "#919191")
    static let gray700 = UIColor(hex: "#565656")
    static let gray900 = UIColor(hex: "#212121")
    
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    // MARK: - RGB 초기화
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) {
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
}
