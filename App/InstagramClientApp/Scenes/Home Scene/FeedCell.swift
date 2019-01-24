//
//  HomeFeedCell.swift
//  InstagramClientApp
//
//  Created by 심승민 on 18/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

protocol FeedCellDelegate {
    func didProfileImageUrlSet(_ loadableImageView: FeedCell, _ url: URL, _ completion: @escaping (Data) -> Void)
    func didPostImageUrlSet(_ loadableImageView: FeedCell, _ url: URL, _ completion: @escaping (Data) -> Void)
    
    func didTapLikeButton()
    func didTapCommentButton()
    func didTapSendMeesageButton()
    func didTapBookMarkButton()
    func didTapOptionButton()
}

final class FeedCell: UICollectionViewCell {
    
    var delegate: FeedCellDelegate?
    var profileImageUrlString: String?  { didSet { profileImageView.imageUrlString = profileImageUrlString } }
    var postImageUrlString: String?  { didSet { postImageView.imageUrlString = postImageUrlString } }
    
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
        delegate?.didTapCommentButton()
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
    
    func setAttributedCaptionLabel(username: String, caption: String, createdDate: String) {
        let attributedText = NSMutableAttributedString(string: username,
                                                       attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: " "+caption,
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: "\n\n",
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 4)]))
        attributedText.append(NSAttributedString(string: createdDate,
                                                 attributes: [
                                                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.gray]))
        
        captionLabel.attributedText = attributedText
    }
}

extension FeedCell: LoadableImageViewDelegate {
    func imageUrlString(_ loadableImageView: LoadableImageView) -> String? {
        if loadableImageView == profileImageView {
            return profileImageUrlString
        } else if loadableImageView == postImageView {
            return postImageUrlString
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
