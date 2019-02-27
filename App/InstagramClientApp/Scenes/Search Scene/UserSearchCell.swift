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
    
    static let reuseId = "UserSearchCell"

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var delegate: UserSearchCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.layer.masksToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        usernameLabel.text = nil
    }
}
