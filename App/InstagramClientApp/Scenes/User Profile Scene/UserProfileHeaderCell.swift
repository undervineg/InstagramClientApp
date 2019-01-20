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
    @IBOutlet weak var editFollowButton: UIButton!
    @IBOutlet weak var gridButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    private var editFollowButtonCallback: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        
        editFollowButton.layer.borderColor = UIColor.lightGray.cgColor
        editFollowButton.layer.borderWidth = 1
    }
    
    enum ButtonType {
        typealias ButtonCallback = () -> Void
        
        case edit(ButtonCallback)
        case follow(ButtonCallback)
    }
    
    func toggleEditFollowButton(_ type: ButtonType) {
        switch type {
        case .edit(let callback):
            editFollowButton.setTitle("Edit Profile", for: .normal)
            editFollowButtonCallback = callback
        case .follow(let callback):
            editFollowButton.setTitle("Follow", for: .normal)
            editFollowButtonCallback = callback
        }
        
        editFollowButton.addTarget(self, action: #selector(handleEditFollowButton), for: .touchUpInside)
    }
    
    @objc private func handleEditFollowButton(_ sender: UIButton) {
        self.editFollowButtonCallback?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        usernameLabel.text = nil
        postLabel.text = nil
        followerLabel.text = nil
        followingLabel.text = nil
        editFollowButtonCallback = nil
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
