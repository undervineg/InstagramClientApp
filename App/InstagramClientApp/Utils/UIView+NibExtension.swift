//
//  UIView+NibExtension.swift
//  InstagramClientApp
//
//  Created by 심승민 on 23/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

extension UIView {
    class func nibFromClassName() -> UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
    
    class func viewFromNib() -> UIView? {
        return Bundle.main.loadNibNamed(String(describing: self), owner: self, options: nil)?.first as? UIView
    }
}
