//
//  UserSearchCell.swift
//  InstagramClientApp
//
//  Created by 심승민 on 20/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

protocol UserSearchCellDelegate {
    func didProfileUrlSet(_ userSearchCell: UserSearchCell, _ url: URL, _ completion: @escaping (Data) -> Void)
}

final class UserSearchCell: UICollectionViewCell {

    @IBOutlet weak var profileImageView: LoadableImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var delegate: UserSearchCellDelegate?
    var profileImageUrlString: String? { didSet { profileImageView.imageUrlString = profileImageUrlString } }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.layer.masksToBounds = true
        
        profileImageView.delegate = self
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        usernameLabel.text = nil
    }
}

extension UserSearchCell: LoadableImageViewDelegate {
    func didImageUrlSet(_ loadableImageView: LoadableImageView, _ url: URL, _ completion: @escaping (Data) -> Void) {
        delegate?.didProfileUrlSet(self, url, completion)
    }
}
