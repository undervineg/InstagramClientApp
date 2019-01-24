//
//  HomeFeedCell.swift
//  InstagramClientApp
//
//  Created by 심승민 on 18/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

protocol FeedCellDelegate {
    func didProfileImageUrlSet(_ loadableImageView: FeedCell, _ url: URL, _ completion: @escaping (Data) -> Void)
    func didPostImageUrlSet(_ loadableImageView: FeedCell, _ url: URL, _ completion: @escaping (Data) -> Void)
    
    func didTapLikeButton()
    func didTapCommentsButton(_ post: Post)
    func didTapSendMeesageButton()
    func didTapBookMarkButton()
    func didTapOptionButton()
}

final class FeedCell: UICollectionViewCell {
    
    var delegate: FeedCellDelegate?
    var profileImageUrlString: String? { didSet { profileImageView.imageUrlString = profileImageUrlString } }
    var post: Post? { didSet { setPostDataToSubviews() } }
    
    @IBOutlet weak var profileImageView: LoadableImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postImageView: LoadableImageView!
    @IBOutlet weak var captionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.layer.masksToBounds = true
        
        profileImageView.delegate = self
        postImageView.delegate = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        usernameLabel.text = nil
        postImageView.image = nil
        captionLabel.text = nil
    }

    // MARK: Actions
    @IBAction func handleLikeButton(_ sender: UIButton) {
        delegate?.didTapLikeButton()
    }
    
    @IBAction func handleCommentButton(_ sender: UIButton) {
        guard let post = post else { return }
        delegate?.didTapCommentsButton(post)
    }
    
    @IBAction func handleSendMessageButton(_ sender: UIButton) {
        delegate?.didTapSendMeesageButton()
    }
    
    @IBAction func handleBookMarkButton(_ sender: UIButton) {
        delegate?.didTapBookMarkButton()
    }
    
    @IBAction func handleOptionButton(_ sender: UIButton) {
        delegate?.didTapOptionButton()
    }
    
    private func setPostDataToSubviews() {
        guard let post = post else { return }
        
        usernameLabel.text = post.user.username
        
        captionLabel.setCaptionText(username: post.user.username,
                                    caption: post.caption,
                                    createdDate: post.creationDate.timeAgoDisplay())
        
        postImageView.imageUrlString = post.imageUrl
    }
}

extension FeedCell: LoadableImageViewDelegate {
    func imageUrlString(_ loadableImageView: LoadableImageView) -> String? {
        if loadableImageView == profileImageView {
            return profileImageUrlString
        } else if loadableImageView == postImageView {
            return post?.imageUrl
        }
        return nil
    }
    
    func requestImageDownload(_ loadableImageView: LoadableImageView, _ url: URL, _ completion: @escaping (Data) -> Void) {
        if loadableImageView == profileImageView {
            delegate?.didProfileImageUrlSet(self, url, completion)
        } else if loadableImageView == postImageView {
            delegate?.didPostImageUrlSet(self, url, completion)
        }
    }
}

extension UILabel {
    fileprivate func setCaptionText(username: String, caption: String, createdDate: String) {
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
