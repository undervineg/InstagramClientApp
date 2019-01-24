//
//  XibLoadable.swift
//  InstagramClientApp
//
//  Created by 심승민 on 24/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

protocol XibLoadable {
    var xibName: String { get set }
    var contentView: UIView! { get set }
    
    func loadViewFromXib()
}

extension XibLoadable where Self: UIView {
    func loadViewFromXib() {
        Bundle.main.loadNibNamed(xibName, owner: self, options: nil)
        
        contentView.frame = self.bounds
        addSubview(contentView)
    }
}
