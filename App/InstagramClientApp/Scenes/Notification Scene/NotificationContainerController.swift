//
//  NotificationContainerController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 22/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import XLPagerTabStrip

final class NotificationContainerController: ButtonBarPagerTabStripViewController {

    private var subViewControllers: [UIViewController] = []
    
    private var isInitialAppeared: Bool = true
    
    convenience init(_ vc1: UIViewController, _ vc2: UIViewController) {
        self.init()
        subViewControllers = [vc1, vc2]
    }
    
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarMinimumInteritemSpacing = 0
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.buttonBarItemFont = UIFont.boldSystemFont(ofSize: 18)
        settings.style.buttonBarItemTitleColor = .black
        settings.style.selectedBarBackgroundColor = .black
        settings.style.selectedBarHeight = 1.25
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, _, changeCurrentIndex: Bool, _) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .lightGray
            newCell?.label.textColor = .black
        }
        
        buttonBarView.layer.drawBottomBorder(0.5, .lightGray)
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isInitialAppeared = false
    }
    
    override var currentIndex: Int {
        return isInitialAppeared ? 1 : super.currentIndex
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return subViewControllers
    }
}
