//
//  EditableTextView.swift
//  InstagramClientApp
//
//  Created by 심승민 on 03/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class EditableTextView: UITextView {

    private let placeholderLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Enter Comment"
        lb.textColor = .lightGray
        return lb
    }()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        isScrollEnabled = false
        
        addPlaceholderLabel()
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlaceholder), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func showPlaceholder() {
        placeholderLabel.isHidden = false
    }
    
    // MARK: Actions
    @objc private func handlePlaceholder(_ sender: NSNotification) {
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    // MARK: Private Methods
    private func addPlaceholderLabel() {
        addSubview(placeholderLabel)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8)
        ])
    }
}
