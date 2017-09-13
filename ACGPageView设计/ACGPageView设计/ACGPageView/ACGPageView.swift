//
//  ACGPageView.swift
//  ACGPageView设计
//
//  Created by 橙纸先森， on 2017/9/8.
//  Copyright © 2017年 Joker. All rights reserved.
//

import UIKit


class ACGPageView: UIView {
   
 
    
    // MARK:- 定义属性 保存传来的参数
    fileprivate var titles : [String]
    fileprivate var childVcs : [UIViewController]
    fileprivate var parentVc : UIViewController
    fileprivate var style : ACGTitleStyle
    
    fileprivate var titleView : ACGTitleView!
    // MARK:- 构造函数                       
    init(frame : CGRect, titles : [String], childVcs : [UIViewController], parentVc : UIViewController, style : ACGTitleStyle) {
        self.titles = titles
        self.childVcs = childVcs
        self.parentVc = parentVc
        self.style = style
        
        super.init(frame: frame)
        //设置UI
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("不能从xib中加载")
    }
    
}


// MARK:- 设置UI界面内容
extension ACGPageView {
    fileprivate func setupUI() {
       
        setupTitleView()
        setupContentView()
        
    }
    // 1.添加titleView到pageView中
    private func setupTitleView() {
        let titleFrame = CGRect(x: 0, y: 0, width: bounds.width, height: style.titleHeight)
        titleView = ACGTitleView(frame:titleFrame, titles: titles, style : style)
        addSubview(titleView)
        titleView.backgroundColor = UIColor.green
       
        
    }
    // 2.添加contentView到pageView中
    //用ScrollView还得设置循环利用 而ContentView会直接设置好
    private func setupContentView() {
        //?. 取到类型一定是可选类型
        let contentFrame = CGRect(x: 0, y: style.titleHeight, width: bounds.width, height: bounds.height - style.titleHeight)
        let contentView = ACGContentView(frame: contentFrame, childVcs:childVcs, parentVc: parentVc)
        contentView.backgroundColor =  UIColor.randomColor()
        addSubview(contentView)
        // 让contentView & TitleView代理
        titleView.delegate = contentView
        contentView.delegeta = titleView 
    }
    
    
    
}
