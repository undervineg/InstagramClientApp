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
    private let commentTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter Comment"
        return tf
    }()
    
    private let commentSubmitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Submit", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        return btn
    }()
    
    var delegate: CommentInputAccessaryViewDelegate?
    
    // MARK: Initializer
    init() {
        super.init(frame: .zero)
        
        addButton(commentSubmitButton)
        addTextField(commentTextField, nextTo: commentSubmitButton)
        addLineSeparatorView()
        
        commentSubmitButton.addTarget(self, action: #selector(handleSubmit(_:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: API
    func clearTextField() {
        commentTextField.text = nil
    }
    
    // MARK: Private methods
    @objc private func handleSubmit(_ sender: UIButton) {
        guard let commentText = commentTextField.text, commentText.count > 0 else { return }
        
        delegate?.didSubmitButtonTapped(self, with: commentText)
    }
    
    private func addButton(_ btn: UIButton) {
        addSubview(btn)
        btn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            btn.topAnchor.constraint(equalTo: topAnchor),
            btn.bottomAnchor.constraint(equalTo: bottomAnchor),
            btn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            btn.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func addTextField(_ tf: UITextField, nextTo btn: UIButton) {
        addSubview(tf)
        tf.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tf.topAnchor.constraint(equalTo: topAnchor),
            tf.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            tf.bottomAnchor.constraint(equalTo: bottomAnchor),
            tf.trailingAnchor.constraint(equalTo: btn.leadingAnchor)
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
