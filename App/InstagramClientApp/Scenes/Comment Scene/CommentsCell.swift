//
//  CommentsCell.swift
//  InstagramClientApp
//
//  Created by 심승민 on 25/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

protocol CommentsCellDelegate {
    func didProfileImageUrlSet(_ cell: CommentsCell, _ url: URL, _ completion: @escaping (Data) -> Void)
}

final class CommentsCell: UICollectionViewCell {
    @IBOutlet weak var profileImageView: LoadableImageView!
    @IBOutlet weak var textView: UITextView!
    
    var delegate: CommentsCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.delegate = self
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        textView.text = nil
    }
}

extension CommentsCell: LoadableImageViewDelegate {
    func didImageUrlSet(_ loadableImageView: LoadableImageView, _ url: URL, _ completion: @escaping (Data) -> Void) {
        delegate?.didProfileImageUrlSet(self, url, completion)
    }
}

extension UITextView {
    func setCommentText(username: String, text: String, createdDate: String) {
        let attributedText = NSMutableAttributedString(string: username,
                                                       attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: " "+text,
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: "\n\n",
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 4)]))
        attributedText.append(NSAttributedString(string: createdDate,
                                                 attributes: [
                                                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.gray]))
        
        self.attributedText = attributedText
    }
}
