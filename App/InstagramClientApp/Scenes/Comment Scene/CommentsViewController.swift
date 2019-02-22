//
//  CommentsViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 04/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

private let cellId = "Cell"

final class CommentsViewController: UIViewController {
    // MARK: Commands
    var submitComment: ((String, Double, String) -> Void)?
    var loadCommentsForPost: ((String, Comment.Order) -> Void)?
    var downloadProfileImage: ((URL, @escaping (Result<Data, UserProfileUseCase.Error>) -> Void) -> Void)?

    // MARK: UI Properties
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let keyboardContainerView = CommentInputAccessaryView()

    private var collectionViewTopAnchor: NSLayoutConstraint?
    private var containerViewBottomAnchor: NSLayoutConstraint?
    
    override var canBecomeFirstResponder: Bool { return true }

    // MARK: Models
    private var currentPostId: String?
    private var commentsForPost: [Comment] = []

    private var cacheManager: Cacheable?
    private let order: Comment.Order = .creationDate(.ascending)

    // MARK: Initializer
    convenience init(currentPostId: String, cacheManager: Cacheable) {
        self.init()
        self.currentPostId = currentPostId
        self.cacheManager = cacheManager
    }

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Comments"
        
        configureKeyboardContainerView()
        configureCollectionView()
        
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

    override func viewWillDisappear(_  animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Actions
    @objc private func keyboardWillChange(_ sender: NSNotification) {
//        guard commentsForPost.count > 0 else { return }
        guard
            let keyboardBeginFrame = (sender.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let keyboardEndFrame = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            !keyboardBeginFrame.equalTo(keyboardEndFrame) else { return }
        
        switch sender.name {
        case UIResponder.keyboardWillShowNotification:
            changeUIForKeyboard(-keyboardEndFrame.height, -keyboardEndFrame.height) { (lastCellAttributes) in
                collectionView.contentInset.top += lastCellAttributes.frame.height * 2.5
                collectionView.contentOffset.y += lastCellAttributes.frame.height
            }
//            if collectionView.visibleCells.count < commentsForPost.count {
//                collectionViewTopAnchor?.constant = -keyboardEndFrame.height
//                let lastCell = IndexPath(item: commentsForPost.count - 1, section: 0)
//                if let lastCellAttributes = collectionView.layoutAttributesForItem(at: lastCell) {
//                    collectionView.contentInset.top += lastCellAttributes.frame.height * 2.5
//                    collectionView.contentOffset.y += lastCellAttributes.frame.height
//                }
//            }
//            containerViewBottomAnchor?.constant = -keyboardEndFrame.height
        case UIResponder.keyboardWillHideNotification:
            changeUIForKeyboard(0, 0) { (lastCellAttributes) in
                collectionView.contentInset.top = 0
                if collectionView.contentOffset.y > -lastCellAttributes.frame.height {
                    collectionView.contentOffset.y -= lastCellAttributes.frame.height
                }
            }
//            if collectionView.visibleCells.count < commentsForPost.count {
//                collectionViewTopAnchor?.constant = 0
//                let lastCell = IndexPath(item: commentsForPost.count - 1, section: 0)
//                if let lastCellAttributes = collectionView.layoutAttributesForItem(at: lastCell) {
//                    collectionView.contentInset.top = 0
//                    if collectionView.contentOffset.y > -lastCellAttributes.frame.height {
//                        collectionView.contentOffset.y -= lastCellAttributes.frame.height
//                    }
//                }
//            }
//            containerViewBottomAnchor?.constant = 0
        default: break
        }
        
        let duration = ((sender.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]) as? NSNumber)?.doubleValue ?? 1

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })

        collectionView.scrollIndicatorInsets = collectionView.contentInset
    }
    
    private func changeUIForKeyboard(_ collectionViewTop: CGFloat, _ containerViewBottom: CGFloat, handlerForLastCell: (UICollectionViewLayoutAttributes) -> Void) {
        if collectionView.visibleCells.count < commentsForPost.count {
            collectionViewTopAnchor?.constant = collectionViewTop
            let lastCell = IndexPath(item: commentsForPost.count - 1, section: 0)
            if let lastCellAttributes = collectionView.layoutAttributesForItem(at: lastCell) {
                handlerForLastCell(lastCellAttributes)
            }
        }
        containerViewBottomAnchor?.constant = containerViewBottom
    }
    
    @objc private func keyboardContainerViewDidDragged(_ gesture: UIPanGestureRecognizer) {
        let velocity = gesture.velocity(in: keyboardContainerView)
        guard abs(velocity.x) < abs(velocity.y), velocity.y > 0 else { return }
        
        keyboardContainerView.endEditing(true)
    }
    
    @objc private func collectionViewDidTap(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

extension CommentsViewController: UICollectionViewDataSource {
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return commentsForPost.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentsCell

        cell.delegate = self
        cell.profileImageView.cacheManager = self.cacheManager

        if commentsForPost.count > 0 {
            let comment = commentsForPost[indexPath.item]
            cell.profileImageView.imageUrlString = comment.user.imageUrl
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
        commentsForPost.append(comment)
        commentsForPost.sort { (c1, c2) -> Bool in
            let compareResult = c1.creationDate.compare(c2.creationDate)
            switch order.sortBy {
            case .ascending: return compareResult == .orderedAscending
            case .descending: return compareResult == .orderedDescending
            }
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.scrollToLastItem(animated: true)
        }
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

    private func scrollToLastItem(animated: Bool) {
        guard commentsForPost.count > 0 else { return }
        let lastIndexPath = IndexPath(item: commentsForPost.count - 1, section: 0)
        collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: animated)
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionViewTopAnchor = collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        NSLayoutConstraint.activate([
            collectionViewTopAnchor!,
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: keyboardContainerView.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        collectionView.backgroundColor = .white
        collectionView.register(CommentsCell.nibFromClassName(), forCellWithReuseIdentifier: cellId)
        collectionView.alwaysBounceVertical = true
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(collectionViewDidTap(_:)))
        collectionView.addGestureRecognizer(tapGesture)
    }
    
    private func configureKeyboardContainerView() {
        view.addSubview(keyboardContainerView)
        keyboardContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerViewBottomAnchor = keyboardContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        NSLayoutConstraint.activate([
            keyboardContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerViewBottomAnchor!,
            keyboardContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(keyboardContainerViewDidDragged(_:)))
        dragGesture.maximumNumberOfTouches = 1
        keyboardContainerView.addGestureRecognizer(dragGesture)
    }
}
