//
//  ACGTitleView.swift
//  ACGPageView设计
//
//  Created by 橙纸先森， on 2017/9/8.
//  Copyright © 2017年 Joker. All rights reserved.
//

import UIKit

//代理传值 通知content跟随文字滚动
protocol ACGTitleViewDelegate : class {     // 用NSObjectProtocol 不够轻量级 所以写class 是为了只让类遵守 好使用weak 不跟结构体 枚举发生冲突
    func titleView(_ titleView : ACGTitleView, targetIndex : Int)
}

class ACGTitleView: UIView {
    
    weak var delegate : ACGTitleViewDelegate?    //代理必须用weak 防止循环引用
    
    // MARK:- 定义属性
    fileprivate var titles : [String]
    fileprivate var style : ACGTitleStyle
    
    fileprivate lazy var currentIndex : Int = 0       //当前选中的titlelabel下标
    
    fileprivate lazy var titleLabels : [UILabel] = [UILabel]() //这个数组用于保存之前遍历出来titleLabel
    fileprivate lazy var scrollView : UIScrollView = {    //block遇到self 要用弱引用
        let scrollView = UIScrollView(frame: self.bounds) //这个不会形成循环引用 这里闭包对当前对象形成强引用 但是当前没有对闭包强引用  而是对UIScrollView的强引用
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        return scrollView
    }()
    fileprivate lazy var bottomLine : UIView = {
        let bottomLine = UIView()
        bottomLine.backgroundColor = self.style.bottomLineColor
        bottomLine.frame.size.height = self.style.bottomLineHeight
        bottomLine.frame.origin.y = self.bounds.height - self.style.bottomLineHeight
        return bottomLine
    }()
    
    // MARK:- 构造函数
    init(frame:CGRect, titles : [String], style : ACGTitleStyle) {
        self.titles = titles
        self.style = style
  
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
// MARK:- 设置UI界面
extension ACGTitleView {
    fileprivate func setupUI() {
        //1.将UIScrollView加入到View中
        addSubview(scrollView)
        //2.将titleLabels添加到UIScrollView中
        setupTitleLabels()
        //3.设置titleLabel的frame
        setupTitleLabelFrame()
        // 4.设置BottomLine
        setupBottomLine()

        
        
    }
    private func setupTitleLabels() {
        //这种遍历既能拿到title 又能拿到i下标
        for (i, title) in titles.enumerated() {
            //1.创建titleLabel
            let titleLabel = UILabel()
           
            //2.设置titleLabel属性
            titleLabel.text = title
            titleLabel.font = style.fontSize
            titleLabel.tag = i
            titleLabel.textAlignment = .center
            //设置默认第一个是选中状态的颜色
            titleLabel.textColor = i == 0 ? style.selectColor : style.normalColor
            
            //3.添加到父控件中
            scrollView.addSubview(titleLabel)
            //4.把所有遍历出来的titleLabel添加到数组
            titleLabels.append(titleLabel)
    
            let tapGes = UITapGestureRecognizer(target: self, action:#selector(titleLabelClick(_ :)))
            titleLabel.addGestureRecognizer(tapGes)
            titleLabel.isUserInteractionEnabled = true //是否允许与用户交互
        }
        
    }
    private func setupTitleLabelFrame() {
        let titlesCount = titles.count
        
        for (i, label) in titleLabels.enumerated() {
            var x : CGFloat = 0
            let y : CGFloat = 0
            var w : CGFloat = 0
            let h : CGFloat = bounds.height
            
            if style.isScrollEnable {  //可以滚动
                //根据文字计算宽度高度
                w = (titles[i] as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 0), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName : label.font], context: nil).width
                
                if i == 0 {
                    x = style.itemMargin * 0.5   //第0个titleLabel时候的 x点
                    //底部滚动条设置
                    if style.isShowBottomLine {
                        bottomLine.frame.origin.x = x
                        bottomLine.frame.size.width = w
                    }
                }
                else
                {
                    let preLabel = titleLabels[i - 1]  //上一个label
                    x = preLabel.frame.maxX + style.itemMargin
                }
            }
            else   //不能滚动
            {
                w = bounds.width / CGFloat(titlesCount)
                x = w * CGFloat(i)
              
                if i == 0 && style.isShowBottomLine {
                    bottomLine.frame.origin.x = 0
                    bottomLine.frame.size.width = w
                }
            }
            label.frame  = CGRect(x: x, y: y, width: w, height: h)
            if style.isTitleScale && i == 0 {
                label.transform = CGAffineTransform(scaleX: style.scaleRange, y: style.scaleRange)
            }
        }
        //设置scrollView 滚动范围
        scrollView.contentSize = style.isScrollEnable ? CGSize(width: titleLabels.last!.frame.maxX + style.itemMargin * 0.5, height: 0) : CGSize.zero
    }
    
    private func setupBottomLine() {
        // 1.判断是否需要显示底部线段
        guard style.isShowBottomLine else { return }
        
        // 2.将bottomLine添加到titleView中
        scrollView.addSubview(bottomLine)
        
        // 3.设置frame
        bottomLine.frame.origin.x = titleLabels.first!.frame.origin.x
        bottomLine.frame.origin.y = bounds.height - style.bottomLineHeight
        bottomLine.frame.size.width = titleLabels.first!.bounds.width
    }
    
    
}

// MARK:- 监听手势点击事件
extension ACGTitleView {
    @objc fileprivate func titleLabelClick(_ tapGes : UITapGestureRecognizer) {
        
        //1.取出用户所点击的View
        let targetLabel = tapGes.view as! UILabel    //目标lab
        let sourceLabel = titleLabels[currentIndex]
       
        //2.通知ContentView代理 内容View改变当前的位置
        delegate?.titleView(self, targetIndex: currentIndex)
       
        //3.调整BottomLine
        if style.isShowBottomLine {
            UIView.animate(withDuration: 0.20, animations: {
                self.bottomLine.frame.origin.x = targetLabel.frame.origin.x
                self.bottomLine.frame.size.width = targetLabel.frame.width
            })
        }
        
        // 4.调整缩放比例
        if style.isTitleScale {
            targetLabel.transform = sourceLabel.transform
            sourceLabel.transform = CGAffineTransform.identity
        }
        
        //5.调整title位置
        adjustTitleLabel(targetIndex: targetLabel.tag)
    }
    fileprivate func adjustTitleLabel(targetIndex : Int) {
        if targetIndex == currentIndex { return }
        //1.取出lab
        let sourceLabel = titleLabels[currentIndex]
        let targetLabel = titleLabels[targetIndex]
        //2.切换文字颜色
        sourceLabel.textColor = style.normalColor
        targetLabel.textColor = style.selectColor
        //3.记录下标值
        currentIndex = targetIndex
        //4. 调整位置
        if style.isScrollEnable {
            var offsetX = targetLabel.center.x - scrollView.bounds.width * 0.5
            //设置第一个和最后一个的偏移量
            if offsetX < 0  {
                offsetX = 0
            }
            if offsetX > (scrollView.contentSize.width - scrollView.bounds.width) {
                offsetX = scrollView.contentSize.width - scrollView.bounds.width
            }
            
            scrollView.setContentOffset(CGPoint(x: offsetX , y: 0), animated: true)
        }
    }
}
// MARK:- 遵守自定义ACGContentViewDelegate协议
extension ACGTitleView : ACGContentViewDelegate {
    func contentView(_ contentView: ACGContentView, targetIndex: Int) {
      adjustTitleLabel(targetIndex: targetIndex)
    }
    func contentView(_ contentView: ACGContentView, sourceIndex: Int, targetIndex: Int, progress: CGFloat) {
        //1.取出lab
        let sourceLabel = titleLabels[sourceIndex]
        let targetLabel = titleLabels[targetIndex]
       
        //2.文字颜色渐变
        let deltaRGB = UIColor.getRGBDelta(style.selectColor, style.normalColor)
        let selectRGB = style.selectColor.getRGB()
        let normalRGB = style.normalColor.getRGB()
        //目标下个lab 默认颜色 + 差值 *拖动的进度
        targetLabel.textColor = UIColor(r: normalRGB.0 + deltaRGB.0 * progress, g: normalRGB.1 + deltaRGB.1 * progress, b: normalRGB.2 + deltaRGB.2 * progress)
        //原目标lab
        sourceLabel.textColor = UIColor(r: selectRGB.0 - deltaRGB.0 * progress, g: selectRGB.1 - deltaRGB.1 * progress, b: selectRGB.2 - deltaRGB.2 * progress)
        
        // 3.渐变BottomLine 计算滚动的范围差值
        if style.isShowBottomLine {
            let deltaX = targetLabel.frame.origin.x - sourceLabel.frame.origin.x
            let deltaW = targetLabel.frame.width - sourceLabel.frame.width
            bottomLine.frame.origin.x = sourceLabel.frame.origin.x + deltaX * progress
            bottomLine.frame.size.width = sourceLabel.frame.width + deltaW * progress
        }
        
        // 4.调整缩放
        if style.isTitleScale {
            let deltaScale = style.scaleRange - 1.0
            sourceLabel.transform = CGAffineTransform(scaleX: style.scaleRange - deltaScale * progress, y: style.scaleRange - deltaScale * progress)
            targetLabel.transform = CGAffineTransform(scaleX: 1.0 + deltaScale * progress, y: 1.0 + deltaScale * progress)
        }

    }
}


