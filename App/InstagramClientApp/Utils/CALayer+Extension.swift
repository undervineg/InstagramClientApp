//
//  CALayer+Extension.swift
//  InstagramClientApp
//
//  Created by 심승민 on 22/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

extension CALayer {
    func drawBottomBorder(_ lineWidth: CGFloat, _ lineColor: UIColor) {
        let borderLayer = CALayer()
        borderLayer.frame = CGRect(x: 0,
                                   y: frame.height - lineWidth,
                                   width: frame.width,
                                   height: lineWidth)
        borderLayer.backgroundColor = lineColor.cgColor
        addSublayer(borderLayer)
    }
}
