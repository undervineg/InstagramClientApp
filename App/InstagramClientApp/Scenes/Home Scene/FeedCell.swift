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
    func didProfileImageUrlSet(_ cell: FeedCell, _ url: URL, _ completion: @escaping (Data) -> Void)
    func didPostImageUrlSet(_ cell: FeedCell, _ url: URL, _ completion: @escaping (Data) -> Void)
    
    func didTapLikeButton(_ cell: FeedCell)
    func didTapCommentsButton(_ cell: FeedCell)
    func didTapSendMeesageButton(_ cell: FeedCell)
    func didTapBookMarkButton(_ cell: FeedCell)
    func didTapOptionButton(_ cell: FeedCell)
}

final class FeedCell: UICollectionViewCell {
    
    var delegate: FeedCellDelegate?
    
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

extension FeedCell: LoadableImageViewDelegate {
    func requestImageDownload(_ loadableImageView: LoadableImageView, _ url: URL, _ completion: @escaping (Data) -> Void) {
        if loadableImageView == profileImageView {
            delegate?.didProfileImageUrlSet(self, url, completion)
        } else if loadableImageView == postImageView {
            delegate?.didPostImageUrlSet(self, url, completion)
        }
    }
}

extension UILabel {
    func setCaptionText(username: String?, caption: String?, createdDate: String?) {
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
