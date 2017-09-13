//
//  ACGColor-Extension.swift
//  ACGTV
//
//  Created by 橙纸先森， on 2017/9/7.
//  Copyright © 2017年 Joker. All rights reserved.
//

import UIKit

extension UIColor {
    //在Extension中给系统的类扩充构造函数，只能扩充"便利构造函数"  两个特点 1.在函数体前面加上convenience 2.必须调用self.init
    //RGB
    convenience init(r : CGFloat, g : CGFloat, b : CGFloat, alpha : CGFloat = 1.0) {
        self.init(red: r / 255.0 , green: g / 255.0, blue: b / 255.0, alpha: alpha)
    }
    //16进制颜色 #FF0000 ##FF0000 0xFF0000 #ff0000
    convenience init?(hex : String,alpha : CGFloat = 1.0) {
        // 1.判断字符串的长度是否符合
        guard hex.characters.count >= 6 else {
            return nil
        }
        // 2.字符串转换成大写
        var tempHex = hex.uppercased()
        // 3.判断开头:0x/#/##
        if tempHex.hasPrefix("0x") || tempHex.hasPrefix("#F") {
            tempHex = (tempHex as NSString).substring(from: 2)
        }
        if tempHex.hasPrefix("#") {
            tempHex = (tempHex as NSString).substring(from: 1)
        }
        // 4.分别取出RGB
        //FF --> 255
        var range = NSRange(location: 0, length: 2)
        let rHex = (tempHex as NSString).substring(with: range)
        range.location = 2
        let gHex = (tempHex as NSString).substring(with: range)
        range.location = 4
        let bHex = (tempHex as NSString).substring(with: range)
        // 5.将16进制转换成数字
        var r : UInt32 = 0, g : UInt32 = 0, b : UInt32 = 0
        Scanner(string: rHex).scanHexInt32(&r)
        Scanner(string: gHex).scanHexInt32(&g)
        Scanner(string: bHex).scanHexInt32(&b)
        
        self.init(r : CGFloat(r), g : CGFloat(g), b : CGFloat(b))
    }
    //添加类方法 随机颜色
    class func randomColor() -> UIColor {
      return  UIColor(r: CGFloat(arc4random_uniform(256)), g: CGFloat(arc4random_uniform(256)), b: CGFloat(arc4random_uniform(256)))
    }
    //RGB的差值
    class  func getRGBDelta(_ firstColor : UIColor, _ seccondColor : UIColor) -> (CGFloat,CGFloat,CGFloat) {
        let firstRGB = firstColor.getRGB()
        let seccondRGB = seccondColor.getRGB()
        //取出差值
        return (firstRGB.0 - seccondRGB.0, firstRGB.1 - seccondRGB.1, firstRGB.2 - seccondRGB.2)
        
    }
    func getRGB() -> (CGFloat, CGFloat, CGFloat) {
        guard let Cmps = cgColor.components else {
            fatalError("保证颜色是RGB颜色传入")
        }
        return (Cmps[0] * 255, Cmps[1] * 255, Cmps[2] * 255)
    }
    
}
