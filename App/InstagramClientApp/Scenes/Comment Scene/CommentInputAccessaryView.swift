//
//  CommentAccessaryView.swift
//  InstagramClientApp
//
//  Created by 심승민 on 02/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

protocol CommentInputAccessaryViewDelegate {
    func didSubmitButtonTapped(_ inputView: CommentInputAccessaryView, with text: String)
}

final class CommentInputAccessaryView: UIView {
    // MARK: UI Properties
    private let commentTextView: EditableTextView = {
        let tv = EditableTextView()
        tv.font = UIFont.systemFont(ofSize: 18)
        return tv
    }()
    
    private let commentSubmitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Submit", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        return btn
    }()
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.bounds.width, height: 50)
    }
    
    var delegate: CommentInputAccessaryViewDelegate?
    
    // MARK: Initializer
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .white
        
        autoresizingMask = .flexibleHeight
        
        addButton(commentSubmitButton)
        addTextView(commentTextView, nextTo: commentSubmitButton)
        addLineSeparatorView()
        
        commentSubmitButton.addTarget(self, action: #selector(handleSubmit(_:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func clearTextView() {
        commentTextView.text = nil
        commentTextView.showPlaceholder()
    }
    
    // MARK: Actions
    @objc private func handleSubmit(_ sender: UIButton) {
        guard let commentText = commentTextView.text, commentText.count > 0 else { return }
        
        delegate?.didSubmitButtonTapped(self, with: commentText)
    }
    
    // MARK: Private methods
    private func addButton(_ btn: UIButton) {
        addSubview(btn)
        btn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            btn.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            btn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            btn.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8),
            btn.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func addTextView(_ tv: UITextView, nextTo btn: UIButton) {
        addSubview(tv)
        tv.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tv.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            tv.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            tv.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8),
            tv.trailingAnchor.constraint(equalTo: btn.leadingAnchor)
        ])
    }
    
    private func addLineSeparatorView() {
        let line = UIView()
        line.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            line.topAnchor.constraint(equalTo: topAnchor),
            line.leadingAnchor.constraint(equalTo: leadingAnchor),
            line.trailingAnchor.constraint(equalTo: trailingAnchor),
            line.heightAnchor.constraint(equalToConstant: 0.7)
        ])
    }
}
