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
    private let keyboardContainerView = CommentInputAccessaryView()
    
    override var inputAccessoryView: UIView? { return keyboardContainerView }
    override var canBecomeFirstResponder: Bool { return true }
    
    // MARK: Models
    private var currentPostId: String?
    private var commentsForPost: [Comment] = []
    
    private var cacheManager: Cacheable?
    private let order: Comment.Order = .creationDate(.ascending)
    
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
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        
        keyboardContainerView.delegate = self
        addKeyboardNotifications()
        
        if let postId = currentPostId {
            loadCommentsForPost?(postId, order)
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
    @objc private func keyboardWillChange(_ sender: NSNotification) {
        guard commentsForPost.count > 0 else { return }
        guard let keyboardFrame = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        switch sender.name {
        case UIResponder.keyboardWillShowNotification:
            if collectionView.frame.origin.y == 0 {
                collectionView.frame.origin.y -= keyboardFrame.height
                collectionView.contentInset.top += keyboardFrame.height
            }
        case UIResponder.keyboardWillHideNotification:
            collectionView.frame.origin.y = 0
            collectionView.contentInset.top = 0
        default: return
        }
        
        collectionView.scrollIndicatorInsets = collectionView.contentInset
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
            cell.textView.setCommentText(username: comment.user.username, text: comment.text, createdDate: comment.creationDate.timeAgoDisplay())
        }
        
        return cell
    }
}

extension CommentsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = generateAutoSizingHeight(at: indexPath)
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension CommentsViewController: CommentInputAccessaryViewDelegate {
    func didSubmitButtonTapped(_ inputView: CommentInputAccessaryView, with text: String) {
        guard let currentPostId = currentPostId else { return }
        
        let submitDate = Date().timeIntervalSince1970
        submitComment?(text, submitDate, currentPostId)
        
        inputView.clearTextView()
    }
}

extension CommentsViewController: CommentsView {
    func displayComment(_ comment: Comment) {
        switch order.sortBy {
        case .ascending:
            commentsForPost.append(comment)
        case .descending:
            commentsForPost.insert(comment, at: 0)
        }
        collectionView.reloadData()
        
        scrollToLastItem()
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

extension CommentsViewController {
    // MARK: Private Methods
    private func generateAutoSizingHeight(at indexPath: IndexPath) -> CGFloat {
        let dummyCell = makeDummyCell(at: indexPath)
        dummyCell.layoutIfNeeded()
        
        let optimalSize = dummyCell.systemLayoutSizeFitting(dummyCell.frame.size)
        let profileImageHeight: CGFloat = 40 + 8 + 8
        return max(profileImageHeight, optimalSize.height)
    }
    
    private func makeDummyCell(at indexPath: IndexPath) -> CommentsCell {
        guard let dummyCell = CommentsCell.viewFromNibFile() as? CommentsCell else {
            fatalError("Casting Error at: \(#function)")
        }
        let comment = commentsForPost[indexPath.item]
        dummyCell.textView.setCommentText(username: comment.user.username, text: comment.text, createdDate: comment.creationDate.timeAgoDisplay())
        return dummyCell
    }
    
    private func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func scrollToLastItem() {
        let lastIndexPath = IndexPath(item: commentsForPost.count - 1, section: 0)
        collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: false)
    }
}
