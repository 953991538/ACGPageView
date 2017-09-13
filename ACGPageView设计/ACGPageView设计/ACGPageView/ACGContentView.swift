//
//  ACGContentView.swift
//  ACGPageView设计
//
//  Created by 橙纸先森， on 2017/9/8.
//  Copyright © 2017年 Joker. All rights reserved.
//

import UIKit
/*
 self.不能省略的情况
       1.在方法中和其他标识符有歧义(重名)
       2.在闭包中self.也不能省略
 */

private let contentCellID = "contentCellID"

protocol ACGContentViewDelegate : class {
    func contentView(_ contentView : ACGContentView, targetIndex : Int)
    func contentView(_ contentView : ACGContentView, sourceIndex: Int, targetIndex : Int, progress : CGFloat)
    
}

class ACGContentView: UIView {
    
    weak var delegeta :ACGContentViewDelegate?
    // MARK:- 定义属性
    fileprivate var childVcs : [UIViewController]
    fileprivate var parentVc : UIViewController
    
    fileprivate var startOffsetX : CGFloat = 0
    fileprivate lazy var isForbidDelegate : Bool = false   //用于点击文字跳转时候 禁止滚动
    fileprivate lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout() //布局流
        layout.itemSize = self.bounds.size //self.bounds.size没有提示
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal //滚动方向
        
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout
        )
        collectionView.dataSource = self //设置数据源
        collectionView.delegate = self   //设置代理监听事件
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: contentCellID) //注册单元格
        collectionView.isPagingEnabled = true //整页滚动
        collectionView.bounces = false       //禁止反弹效果
        collectionView.scrollsToTop = false //禁止点击状态栏滑动到最顶部
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    //// MARK:- 构造函数
    init(frame : CGRect, childVcs : [UIViewController], parentVc : UIViewController) {        
        self.childVcs = childVcs
        self.parentVc = parentVc
        super.init(frame: frame)
        //设置UI
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("不能从xib中加载")
    }
    
}
// MARK:- 设置UI界面
extension ACGContentView {
    fileprivate func setupUI() {
        //1.将所有子控制器加入到父控制器中   最重要的一步不能忘记  不加进去做关于控制器的东西会有问题
        for childVc in childVcs {
            parentVc.addChildViewController(childVc)
        }
        //2.初始化用于显示子控制器View的View（UIScrollView/UICollectionView）
        addSubview(collectionView)

    }
}
// MARK:- 遵守UICollectionViewDataSource协议
extension ACGContentView : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childVcs.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellID, for: indexPath)
        //cell.backgroundColor = UIColor.randomColor()
        for subView in cell.contentView.subviews {     //把之前的子视图删掉  不然可能会出现一直加的状况
            subView.removeFromSuperview()
        }
        
        let childVc = childVcs[indexPath.item]    //取出Item
        childVc.view.frame = cell.contentView.bounds //Item设置填满单元格
        cell.contentView.addSubview(childVc.view)
    
        return cell
        
    }
}
// MARK:- 遵守UICollectionViewDelegate协议
extension ACGContentView : UICollectionViewDelegate {
    //停止减速时候
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        contentEndscoll()
    }
    //停止拖动时候
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
          //没有减速过程的处理
        if !decelerate {
            contentEndscoll()
        }
    }
    private func contentEndscoll() {
        //0.判断是否禁止状态
        guard !isForbidDelegate else {
            return
        }
        
        //1.获取到滚动的位置
        let currentIndex = Int(collectionView.contentOffset.x / collectionView.bounds.width)
        
        //2.通知TitleView 进行调整
        delegeta?.contentView(self, targetIndex: currentIndex)
        
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isForbidDelegate = false
        startOffsetX = scrollView.contentOffset.x
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //0.判断是否和我们开始时的偏移量一致
        guard startOffsetX != scrollView.contentOffset.x, !isForbidDelegate else {
            return
        }
        // 1.定义获取需要的数据
        var progress : CGFloat = 0
        var sourceIndex : Int = 0
        var targetIndex : Int = 0
        
        // 2.判断是左滑还是右滑
        let currentOffsetX = scrollView.contentOffset.x
        let scrollViewW = scrollView.bounds.width
        if currentOffsetX > startOffsetX { // 左滑
            // 1.计算progress
            progress = currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW)
            
            // 2.计算sourceIndex
            sourceIndex = Int(currentOffsetX / scrollViewW)
            
            // 3.计算targetIndex
            targetIndex = sourceIndex + 1
            if targetIndex >= childVcs.count {
                targetIndex = childVcs.count - 1
            }
            
            // 4.如果完全划过去
            if currentOffsetX - startOffsetX == scrollViewW {
                progress = 1
                targetIndex = sourceIndex
            }
        } else { // 右滑
            // 1.计算progress
            progress = 1 - (currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW))
            
            // 2.计算targetIndex
            targetIndex = Int(currentOffsetX / scrollViewW)
            
            // 3.计算sourceIndex
            sourceIndex = targetIndex + 1
            if sourceIndex >= childVcs.count {
                sourceIndex = childVcs.count - 1
            }
        }
        
        //4.通知代理
        delegeta?.contentView(self, sourceIndex:sourceIndex ,targetIndex: targetIndex, progress: progress)
    }
}

// MARK:- 遵守自定义ACGTitleViewDelegate协议
extension ACGContentView : ACGTitleViewDelegate {
    func titleView(_ titleView: ACGTitleView, targetIndex: Int) {
       isForbidDelegate = true

        let indexPath = IndexPath(item: targetIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
    }
}









