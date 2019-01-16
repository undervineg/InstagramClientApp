//
//  UserProfileHeaderCell.swift
//  InstagramClientApp
//
//  Created by 심승민 on 11/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class UserProfileHeaderCell: UICollectionViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var gridButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        
        editProfileButton.layer.borderColor = UIColor.lightGray.cgColor
        editProfileButton.layer.borderWidth = 1
    }
}

extension UIView {
    class func nibFromClassName() -> UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
    
    class func viewFromNib() -> UIView? {
        return Bundle.main.loadNibNamed(String(describing: self), owner: self, options: nil)?.first as? UIView
    }
}
