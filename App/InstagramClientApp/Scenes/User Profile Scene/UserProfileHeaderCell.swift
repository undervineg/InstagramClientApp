//
//  UserProfileHeaderCell.swift
//  InstagramClientApp
//
//  Created by 심승민 on 11/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

final class UserProfileHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageView: LoadableImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var editProfileFollowButton: UIButton!
    @IBOutlet weak var gridButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        
        editProfileFollowButton.layer.cornerRadius = 5
        editProfileFollowButton.layer.masksToBounds = true
        editProfileFollowButton.layer.borderColor = UIColor.lightGray.cgColor
        editProfileFollowButton.layer.borderWidth = 1
    }
    
    enum ButtonType {
        case edit
        case follow
        case unfollow
        
        var title: String {
            switch self {
            case .edit: return "Edit Profile"
            case .follow: return "Follow"
            case .unfollow: return "Unfollow"
            }
        }
    }
    
    func toggleEditFollowButton(_ type: ButtonType) {
        switch type {
        case .edit:
            editProfileFollowButton.setTitle(type.title, for: .normal)
            editProfileFollowButton.backgroundColor = .white
            editProfileFollowButton.setTitleColor(.black, for: .normal)
        case .follow:
            editProfileFollowButton.setTitle(type.title, for: .normal)
            editProfileFollowButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
            editProfileFollowButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
            editProfileFollowButton.setTitleColor(.white, for: .normal)
        case .unfollow:
            editProfileFollowButton.setTitle(type.title, for: .normal)
            editProfileFollowButton.backgroundColor = .white
            editProfileFollowButton.setTitleColor(.black, for: .normal)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        usernameLabel.text = nil
        postLabel.text = nil
        followerLabel.text = nil
        followingLabel.text = nil
    }
    
    func setAttributedText(to label: UILabel, _ dataText: String, _ fixedText: String) {
        let attributedText = NSMutableAttributedString(string: dataText,
                                                       attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "\n",
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 4)]))
        attributedText.append(NSAttributedString(string: fixedText,
                                                 attributes: [
                                                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.gray]))
        
        label.attributedText = attributedText
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
