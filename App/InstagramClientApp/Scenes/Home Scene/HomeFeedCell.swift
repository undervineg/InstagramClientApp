//
//  HomeFeedCell.swift
//  InstagramClientApp
//
//  Created by 심승민 on 18/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

protocol HomeFeedCellDelegate {
    func didTapLikeButton(_ cell: HomeFeedCell)
    func didTapCommentsButton(_ cell: HomeFeedCell)
    func didTapSendMeesageButton(_ cell: HomeFeedCell)
    func didTapBookMarkButton(_ cell: HomeFeedCell)
    func didTapOptionButton(_ cell: HomeFeedCell)
}

final class HomeFeedCell: UICollectionViewCell {
    
    static let reuseId = "HomeFeedCell"
    
    var representedId: UUID?
    
    var delegate: HomeFeedCellDelegate?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var likesButton: UIButton!
    
    func configure(with post: PostObject?) {
        guard let post = post else { return }
        usernameLabel.text = post.user.username
        
        captionLabel.setCaptionText(username: post.user.username,
                                    caption: post.data.caption,
                                    createdDate: post.data.creationDate.timeAgoDisplay())
        
        let likesImageName = post.hasLiked ? "like_selected" : "like_unselected"
        likesButton.setImage(UIImage(named: likesImageName), for: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        usernameLabel.text = nil
        postImageView.image = nil
        captionLabel.text = nil
        likesButton.imageView?.image = nil
    }

    // MARK: Actions
    @IBAction func handleLikeButton(_ sender: UIButton) {
        delegate?.didTapLikeButton(self)
    }
    
    @IBAction func handleCommentButton(_ sender: UIButton) {
        delegate?.didTapCommentsButton(self)
    }
    
    @IBAction func handleSendMessageButton(_ sender: UIButton) {
        delegate?.didTapSendMeesageButton(self)
    }
    
    @IBAction func handleBookMarkButton(_ sender: UIButton) {
        delegate?.didTapBookMarkButton(self)
    }
    
    @IBAction func handleOptionButton(_ sender: UIButton) {
        delegate?.didTapOptionButton(self)
    }
}

extension UILabel {
    fileprivate func setCaptionText(username: String?, caption: String?, createdDate: String?) {
        guard let username = username, let caption = caption, let createdDate = createdDate else { return }
        let attributedText = NSMutableAttributedString(string: username,
                                                       attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: " "+caption,
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: "\n\n",
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 4)]))
        attributedText.append(NSAttributedString(string: createdDate,
                                                 attributes: [
                                                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.gray]))
        
        self.attributedText = attributedText
    }
}
