//
//  HomeFeedCell.swift
//  InstagramClientApp
//
//  Created by 심승민 on 18/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class HomeFeedCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageView: LoadableImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var optionsButton: UIButton!
    
    @IBOutlet weak var postImageView: LoadableImageView!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    @IBOutlet weak var captionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.layer.masksToBounds = true
        
        let attributedText = NSMutableAttributedString(string: "Username",
                                                       attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: " Some caption text that will perhaps wrap onto the next line",
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: "\n\n",
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 4)]))
        attributedText.append(NSAttributedString(string: "1 week ago",
                                                 attributes: [
                                                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.gray]))
        
        captionLabel.attributedText = attributedText
    }

}
