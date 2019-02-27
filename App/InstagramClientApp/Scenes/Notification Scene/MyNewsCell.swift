//
//  MyNewsCell.swift
//  InstagramClientApp
//
//  Created by 심승민 on 22/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

final class MyNewsCell: UITableViewCell {

    static let reuseId = "MyNewsCell"
    var representedId: UUID?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
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
    
    @IBAction func follow(_ sender: UIButton) {
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        messageLabel.text = nil
    }
    
}

extension UILabel {
    func setMessageText(text: String, with emphasizeIndices: [Int], createdDate: String) {
        var stressRanges: [NSRange] = []
        
        emphasizeIndices.enumerated().forEach { (index, startIndex) in
            guard index % 2 == 0 else { return }
            let length = emphasizeIndices[index + 1]
            let range = NSRange(location: startIndex, length: length)
            stressRanges.append(range)
        }
        
        let attributedText = NSMutableAttributedString(string: text,
                                                       attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        stressRanges.forEach { (range) in
            attributedText.addAttribute(NSAttributedString.Key.font,
                                        value: UIFont.boldSystemFont(ofSize: 14),
                                        range: range)
        }
        attributedText.append(NSAttributedString(string: " "+createdDate,
                                                 attributes: [
                                                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: UIColor.gray]))
        
        self.attributedText = attributedText
    }
}
