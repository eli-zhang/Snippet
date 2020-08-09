//
//  Colors.swift
//  Snippet
//
//  Created by Eli Zhang on 7/19/20.
//  Copyright © 2020 Eli Zhang. All rights reserved.
//

import Foundation
import UIKit

struct Colors {
    static let RED = UIColor.fromHex(hex: "#EB3B5A")
    static let ORANGE = UIColor.fromHex(hex: "#FA8231")
    static let WHITE = UIColor.fromHex(hex: "#FFFFFF")
    static let GRAY = UIColor.fromHex(hex: "#C4C4C4")
    static let LIGHTGRAY = UIColor.fromHex(hex: "#F3F3F3")
}


extension UIColor {
    static func fromHex(hex: String) -> UIColor {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
                        
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    return self.init(red: r, green: g, blue: b, alpha: a)
                }
            }
            
            else if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat((hexNumber & 0x0000ff)) / 255
                    return self.init(red: r, green: g, blue: b, alpha: 1)
                }
            }
        }
        return .black
    }
}

