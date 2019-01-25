//
//  UserProfilePhotoCell.swift
//  InstagramClientApp
//
//  Created by 심승민 on 17/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

protocol UserProfilePhotoCellDelegate {
    func didImageUrlSet(_ userProfileHeaderCell: UserProfilePhotoCell, _ url: URL, _ completion: @escaping (Data) -> Void)
}

final class UserProfilePhotoCell: UICollectionViewCell {
    
    var delegate: UserProfilePhotoCellDelegate?
    var postImageUrl: String? { didSet { imageView.imageUrlString = postImageUrl } }
    
    let imageView: LoadableImageView = {
        let iv = LoadableImageView(frame: .zero)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        imageView.delegate = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension UserProfilePhotoCell: LoadableImageViewDelegate {
    func didImageUrlSet(_ loadableImageView: LoadableImageView, _ url: URL, _ completion: @escaping (Data) -> Void) {
        delegate?.didImageUrlSet(self, url, completion)
    }
}
