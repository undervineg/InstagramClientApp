//
//  PostNewsCell.swift
//  InstagramClientApp
//
//  Created by 심승민 on 22/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

protocol NotificationCell: class {
    static var reuseId: String { get }
    var representedId: UUID? { get set }
    var profileImageView: UIImageView! { get }
    var postImageView: UIImageView? { get }
    
    func configure(with data: PushNotification)
}

final class ImageNewsCell: UITableViewCell, NotificationCell {

    static let reuseId = "PostNewsCell"
    var representedId: UUID?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
    }
    
    func configure(with data: PushNotification) {
        let message = data.body
        let creationDate = data.creationDate.timeAgoDisplay()
        let emphasizeIndices = data.emphasizeIndices ?? []
        
        messageLabel.setMessageText(text: message, with: emphasizeIndices, createdDate: creationDate)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        messageLabel.text = nil
        postImageView?.image = nil
    }
}
