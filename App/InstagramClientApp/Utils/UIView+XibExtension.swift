//
//  UIView+XibExtension.swift
//  InstagramClientApp
//
//  Created by 심승민 on 23/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

extension UIView {
    class var classname: String {
        return String(describing: self)
    }
    
    class func nibFromClassName() -> UINib {
        return UINib(nibName: classname, bundle: nil)
    }
    
    class func viewFromNibFile() -> UIView {
        let nib = nibFromClassName()
        guard let view = nib.instantiate(withOwner: classname.self).first as? UIView else {
            fatalError("\(#function): No top level objects in nib")
        }
        return view
    }
}
