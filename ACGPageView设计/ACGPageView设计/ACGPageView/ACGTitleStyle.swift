//
//  ACGTitleStyle.swift
//  ACGPageView设计
//
//  Created by 橙纸先森， on 2017/9/8.
//  Copyright © 2017年 Joker. All rights reserved.
//

import UIKit

class ACGTitleStyle {
    /// 是否是滚动的Title
    var isScrollEnable : Bool = false
    /// titleView的背景颜色
    var titleBgColor : UIColor = .clear
    /// titleView的高度
    var titleHeight : CGFloat = 44
    /// 滚动Title的字体间距
    var itemMargin  : CGFloat = 20
    /// Title字体大小
    var fontSize : UIFont = UIFont.systemFont(ofSize: 14.0)
    /// 普通Title颜色
    var normalColor : UIColor = UIColor(r: 255, g: 255, b: 255)
    /// 选中Title颜
    var selectColor : UIColor = UIColor(r: 255, g: 127, b: 0)
    
    /// 是否显示底部滚动条
    var isShowBottomLine : Bool = false
    /// 底部滚动条的颜色
    var bottomLineColor : UIColor = UIColor.orange
    /// 底部滚动条的高度
    var bottomLineHeight : CGFloat = 2
    
    /// 是否进行缩放
    var isTitleScale : Bool = false
    var scaleRange : CGFloat = 1.2
    
}
