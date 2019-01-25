//
//  CommentsController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 25/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

private let cellId = "Cell"

class CommentsViewController: UICollectionViewController {
    
    var submit: ((String) -> Void)?
    
    private lazy var keyboardContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: 0, height: 50)
        containerView.backgroundColor = .white
        let submitButton = configureSubmitButton(inside: containerView)
        configureTextField(inside: containerView, leftOf: submitButton)
        return containerView
    }()
    
    private var currentPost: Post?

    override var inputAccessoryView: UIView? {
        return keyboardContainerView
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    convenience init(currentPost: Post) {
        let layout = UICollectionViewFlowLayout()
        self.init(collectionViewLayout: layout)
        self.currentPost = currentPost
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        navigationItem.title = "Comments"
        
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
    
        
    
        return cell
    }
    
    // MARK: Actions
    @objc private func handleSubmit(_ sender: UIButton) {
        submit?("example comment")
    }
}

extension CommentsViewController: UICollectionViewDelegateFlowLayout {
    
}

extension CommentsViewController {
    // MARK: Private Methods
    @discardableResult
    private func configureSubmitButton(inside containerView: UIView) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle("Submit", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        containerView.addSubview(btn)
        btn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            btn.topAnchor.constraint(equalTo: containerView.topAnchor),
            btn.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            btn.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            btn.widthAnchor.constraint(equalToConstant: 50)
        ])
        btn.addTarget(self, action: #selector(handleSubmit(_:)), for: .touchUpInside)
        return btn
    }
    
    @discardableResult
    private func configureTextField(inside containerView: UIView, leftOf submitButton: UIButton) -> UITextField {
        let tf = UITextField()
        tf.placeholder = "Enter Comment"
        containerView.addSubview(tf)
        tf.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tf.topAnchor.constraint(equalTo: containerView.topAnchor),
            tf.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            tf.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            tf.trailingAnchor.constraint(equalTo: submitButton.leadingAnchor)
        ])
        return tf
    }
}
