//
//  UIColorExt.swift
//  JSON
//
//  Created by Juan Alvarez on 3/26/15.
//  Copyright (c) 2015 Alvarez Productions. All rights reserved.
//

import UIKit

extension UIColor {
    
    public class func fromRGB(_ r: Int, _ g: Int, _ b: Int) -> UIColor {
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1)
    }
    
    public class func fromHex(_ hex: String) -> UIColor {
      var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
      
      if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
      }
      
      if ((cString.characters.count) != 6) {
        return UIColor.gray
      }
      
      var rgbValue:UInt32 = 0
      Scanner(string: cString).scanHexInt32(&rgbValue)
      
      return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
      )
    }
}
