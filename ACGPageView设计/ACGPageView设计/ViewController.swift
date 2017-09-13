//
//  ViewController.swift
//  ACGPageView设计
//
//  Created by 橙纸先森， on 2017/9/8.
//  Copyright © 2017年 Joker. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false 
        
        //1.标题
//        let titles = ["游戏","娱乐","趣玩","高颜值","美女"]
        let titles = ["推荐", "手游玩法大全", "娱乐手", "游戏游戏", "趣玩", "游戏游戏", "趣玩"]
        let style = ACGTitleStyle()
        style.isScrollEnable = true
        style.isShowBottomLine = true
        style.isTitleScale = true
        //style.titleHeight = 44  默认44
        
        //2.所有的子控制器
        var childVcs = [UIViewController]()
        for _ in 0..<titles.count {
            let vc = UIViewController()
            vc.view.backgroundColor = UIColor.randomColor()
            childVcs.append(vc)
            
        }
        //3.pageView的Frame
        let pageFrame = CGRect(x: 0, y: 64, width: view.bounds.width, height: view.bounds.height - 64)
        
        //4.创建ACGPageView 并且添加到控制器的View中
        let pageView = ACGPageView(frame: pageFrame, titles: titles, childVcs: childVcs, parentVc: self, style: style)
        
        view.addSubview(pageView)
        
    }
}

