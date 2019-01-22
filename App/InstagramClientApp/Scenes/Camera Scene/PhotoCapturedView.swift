//
//  PhotoCapturedView.swift
//  InstagramClientApp
//
//  Created by 심승민 on 23/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class PhotoCapturedView: UIView {

    let capturedImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCapturedImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func configureCapturedImageView() {
        addSubview(capturedImageView)
        capturedImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            capturedImageView.topAnchor.constraint(equalTo: topAnchor),
            capturedImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            capturedImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            capturedImageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
