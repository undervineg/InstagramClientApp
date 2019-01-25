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

final class CommentsViewController: UICollectionViewController {
    // MARK: Commands
    var submitComment: ((String, Double, String) -> Void)?
    var loadCommentsForPost: ((String, Comment.Order) -> Void)?
    var downloadProfileImage: ((URL, @escaping (Result<Data, UserProfileUseCase.Error>) -> Void) -> Void)?
    
    // MARK: UI Properties
    let commentTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter Comment"
        return tf
    }()
    
    private(set) lazy var commentSubmitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Submit", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.addTarget(self, action: #selector(handleSubmit(_:)), for: .touchUpInside)
        return btn
    }()
    
    private(set) lazy var keyboardContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: 0, height: 50)
        containerView.backgroundColor = .white
        containerView.addButton(commentSubmitButton)
        containerView.addTextField(commentTextField, nextTo: commentSubmitButton)
        return containerView
    }()
    
    override var inputAccessoryView: UIView? { return keyboardContainerView }
    override var canBecomeFirstResponder: Bool { return true }
    
    // MARK: Models
    private var currentPostId: String?
    private var commentsForPost: [Comment] = []
    
    private var cacheManager: Cacheable?
    
    // MARK: Initializer
    convenience init(currentPostId: String, cacheManager: Cacheable) {
        let layout = UICollectionViewFlowLayout()
        self.init(collectionViewLayout: layout)
        self.currentPostId = currentPostId
        self.cacheManager = cacheManager
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Comments"
        
        collectionView.backgroundColor = .white
        collectionView.register(CommentsCell.nibFromClassName(), forCellWithReuseIdentifier: cellId)
        collectionView.keyboardDismissMode = .onDrag
        
        if let postId = currentPostId {
            loadCommentsForPost?(postId, .creationDate(.ascending))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: Actions
    @objc private func handleSubmit(_ sender: UIButton) {
        guard let currentPostId = currentPostId else { return }
        guard let commentText = commentTextField.text, commentText.count > 0 else { return }
        
        let submitDate = Date().timeIntervalSince1970
        submitComment?(commentText, submitDate, currentPostId)
        
        commentTextField.text = ""
        commentTextField.resignFirstResponder()
    }
}

extension CommentsViewController: CommentsView {
    func displayComment(_ comment: Comment) {
        commentsForPost.append(comment)
        collectionView.reloadData()
    }
}

extension CommentsViewController {
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return commentsForPost.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentsCell
        
        cell.delegate = self
        cell.profileImageView.cacheManager = self.cacheManager
        
        if commentsForPost.count > 0 {
            let comment = commentsForPost[indexPath.item]
            cell.profileImageView.imageUrlString = comment.user.profileImageUrl
            cell.textLabel.setCommentText(username: comment.user.username, text: comment.text, createdDate: comment.creationDate.timeAgoDisplay())
        }
        
        return cell
    }
}

extension CommentsViewController: CommentsCellDelegate {
    func didProfileImageUrlSet(_ cell: CommentsCell, _ url: URL, _ completion: @escaping (Data) -> Void) {
        downloadProfileImage?(url) { (result) in
            switch result {
            case .success(let imageData): completion(imageData)
            default: return
            }
        }
    }
}

extension CommentsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
}

extension UIView {
    fileprivate func addButton(_ btn: UIButton) {
        addSubview(btn)
        btn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            btn.topAnchor.constraint(equalTo: topAnchor),
            btn.bottomAnchor.constraint(equalTo: bottomAnchor),
            btn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            btn.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    fileprivate func addTextField(_ tf: UITextField, nextTo btn: UIButton) {
        addSubview(tf)
        tf.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tf.topAnchor.constraint(equalTo: topAnchor),
            tf.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            tf.bottomAnchor.constraint(equalTo: bottomAnchor),
            tf.trailingAnchor.constraint(equalTo: btn.leadingAnchor)
        ])
    }
}
