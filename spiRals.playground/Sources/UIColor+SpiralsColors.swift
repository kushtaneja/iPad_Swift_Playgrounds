//
//  UIColor+SpiralsColors.swift
//
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import UIKit

extension UIColor {
    
    var lighterColor: UIColor {
        return lighterColor(removeSaturation: 0.3)
    }
    
    private func lighterColor(removeSaturation value: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 1.0
        
        guard getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            else {return self}
        
        return UIColor(hue: hue,
                       saturation: max(saturation - value, 0.0),
                       brightness: brightness,
                       alpha: alpha)
    }
    
    private static func randomColorComponent() -> CGFloat {
        return CGFloat(arc4random_uniform(1000))/1000.0
    }
    
    static func randomColor() -> UIColor {
        return UIColor(red: randomColorComponent(),
                     green: randomColorComponent(),
                      blue: randomColorComponent(),
                     alpha: 1.0)
    }
    
    public static func appleLogoGreen() -> UIColor {
        return UIColor(red: 98.0/255.0,
                     green: 187.0/255.0,
                      blue: 70.0/255.0,
                     alpha: 1.0)
    }
    
    public static func appleLogoYellow() -> UIColor {
        return UIColor(red: 253.0/255.0,
                     green: 184.0/255.0,
                      blue: 39.0/255.0,
                     alpha: 1.0)
    }
    
    public static func appleLogoOrange() -> UIColor {
        return UIColor(red: 245.0/255.0,
                     green: 130.0/255.0,
                      blue: 31.0/255.0,
                     alpha: 1.0)
    }
    
    public static func appleLogoRed() -> UIColor {
        return UIColor(red: 224.0/255.0,
                     green: 58.0/255.0,
                      blue: 62.0/255.0,
                     alpha: 1.0)
    }
    
    public static func appleLogoPurple() -> UIColor {
        return UIColor(red: 150.0/255.0,
                     green: 61.0/255.0,
                      blue: 151.0/255.0,
                     alpha: 1.0)
    }
    
    public static func appleLogoBlue() -> UIColor {
        return UIColor(red: 1.0/255.0,
                     green: 158.0/255.0,
                      blue: 220.0/255.0,
                     alpha: 1.0)
    }
    
    public static func wwdcGray() -> UIColor {
        return UIColor(red: 23.0/255,
                     green: 24.0/255,
                      blue: 34.0/255,
                     alpha: 1)
    }

}
