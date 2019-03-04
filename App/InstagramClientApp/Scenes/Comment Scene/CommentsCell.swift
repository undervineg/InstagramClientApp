//
//  CommentsCell.swift
//  InstagramClientApp
//
//  Created by 심승민 on 25/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

final class CommentsCell: UICollectionViewCell {
    static let reuseId = "CommentsCell"
    var representedId: UUID?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
    }
    
    func configure(with comment: Comment) {
        textView.setCommentText(username: comment.user.username,
                                text: comment.text,
                                createdDate: comment.creationDate.timeAgoDisplay())
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        textView.text = nil
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
