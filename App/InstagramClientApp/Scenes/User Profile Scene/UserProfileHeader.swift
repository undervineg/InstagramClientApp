//
//  UserProfileHeaderCell.swift
//  InstagramClientApp
//
//  Created by 심승민 on 11/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

protocol UserProfileHeaderDataSource {
    func username(_ userProfileHeaderCell: UserProfileHeader) -> String?
    func userProfileUrl(_ userProfileHeaderCell: UserProfileHeader) -> String?
    func editProfileButtonType(_ userProfileHeaderCell: UserProfileHeader) -> UserProfileHeader.ButtonType
    func summaryCounts(_ userProfileHeaderCell: UserProfileHeader, _ labelType: UserProfileHeader.SummaryLabelType) -> Int
}

protocol UserProfileHeaderDelegate {
    func didProfileUrlSet(_ userProfileHeaderCell: UserProfileHeader, _ url: URL, _ completion: @escaping (Data) -> Void)
    func didTapEditProfileButton(_ userProfileHeaderCell: UserProfileHeader)
    func didTapFollowButton(_ userProfileHeaderCell: UserProfileHeader)
    func didTapUnfollowButton(_ userProfileHeaderCell: UserProfileHeader)
}

final class UserProfileHeader: UICollectionViewCell {
    
    @IBOutlet weak var profileImageView: LoadableImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var editProfileFollowButton: UIButton!
    @IBOutlet weak var gridButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    var delegate: UserProfileHeaderDelegate?
    var dataSource: UserProfileHeaderDataSource? { didSet { setDataToSubviews() } }

    private var currentEditFollowButtonType: ButtonType? { didSet { configureEditFollowButton() } }
    
    enum SummaryLabelType {
        case posts
        case followers
        case followings
        
        var fixedText: String {
            switch self {
            case .posts: return "posts"
            case .followers: return "followers"
            case .followings: return "followings"
            }
        }
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureSubviews()
        
        profileImageView.delegate = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetSubviewsHasData()
    }
    
    // MARK: Actions
    @IBAction func handleEditProfileFollowButton(_ sender: UIButton) {
        guard let type = currentEditFollowButtonType else { return }
        switch type {
        case .edit:
            delegate?.didTapEditProfileButton(self)
        case .follow:
            delegate?.didTapFollowButton(self)
        case .unfollow:
            delegate?.didTapUnfollowButton(self)
        }
    }
}

extension UserProfileHeader: LoadableImageViewDelegate {
    func requestImageDownload(_ loadableImageView: LoadableImageView, _ url: URL, _ completion: @escaping (Data) -> Void) {
        delegate?.didProfileUrlSet(self, url, completion)
    }
}

extension UserProfileHeader {
    // MARK: Private Methods
    private func setDataToSubviews() {
        guard let dataSource = dataSource else { return }
        
        usernameLabel.text = dataSource.username(self)
        
        profileImageView.imageUrlString = dataSource.userProfileUrl(self)
        
        currentEditFollowButtonType = dataSource.editProfileButtonType(self)
        
        configureSummaryLabel(type: .posts)
        configureSummaryLabel(type: .followers)
        configureSummaryLabel(type: .followings)
    }
    
    private func configureSummaryLabel(type: SummaryLabelType) {
        guard let count = dataSource?.summaryCounts(self, type) else { return }
        let fixedText = type.fixedText
        
        switch type {
        case .posts: postLabel.setSummary(count: count, fixedText: fixedText)
        case .followers: followerLabel.setSummary(count: count, fixedText: fixedText)
        case .followings: followingLabel.setSummary(count: count, fixedText: fixedText)
        }
    }
    
    private func configureEditFollowButton() {
        guard let type = currentEditFollowButtonType else { return }
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

    private func configureSubviews() {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        
        editProfileFollowButton.layer.cornerRadius = 5
        editProfileFollowButton.layer.masksToBounds = true
        editProfileFollowButton.layer.borderColor = UIColor.lightGray.cgColor
        editProfileFollowButton.layer.borderWidth = 1
    }
    
    private func resetSubviewsHasData() {
        profileImageView.image = nil
        usernameLabel.text = nil
        postLabel.text = nil
        followerLabel.text = nil
        followingLabel.text = nil
    }
}

extension UILabel {
    fileprivate func setSummary(count: Int, fixedText: String) {
        let attributedText = NSMutableAttributedString(string: "\(count)",
            attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "\n",
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 4)]))
        attributedText.append(NSAttributedString(string: fixedText,
                                                 attributes: [
                                                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.gray]))
        
        self.attributedText = attributedText
    }
}
