//
//  CommentsViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 04/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

final class CommentsViewController: UIViewController, UICollectionViewDataSourcePrefetching {
    // MARK: Commands
    var submitComment: ((String, Double, String) -> Void)?
    var loadCommentsForPost: ((String, Comment.Order) -> Void)?
    var loadProfileImage: ((NSUUID, User, ((UIImage?) -> Void)?) -> Void)?
    var getCachedProfileImage: ((NSUUID) -> UIImage?)?
    var cancelLoadProfileImage: ((NSUUID) -> Void)?
    
    // MARK: UI Properties
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let keyboardContainerView = CommentInputAccessaryView()

    private var collectionViewTopAnchor: NSLayoutConstraint?
    private var containerViewBottomAnchor: NSLayoutConstraint?
    
    override var canBecomeFirstResponder: Bool { return true }

    // MARK: Models
    private var currentPostId: String?
    private var commentsForPost: [CommentObject] = []

    private let order: Comment.Order = .creationDate(.ascending)

    // MARK: Initializer
    convenience init(currentPostId: String) {
        self.init()
        self.currentPostId = currentPostId
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
        
        collectionView.isPrefetchingEnabled = true
        collectionView.prefetchDataSource = self
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
        case UIResponder.keyboardWillHideNotification:
            changeUIForKeyboard(0, 0) { (lastCellAttributes) in
                collectionView.contentInset.top = 0
                if collectionView.contentOffset.y > -lastCellAttributes.frame.height {
                    collectionView.contentOffset.y -= lastCellAttributes.frame.height
                }
            }
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentsCell.reuseId, for: indexPath) as! CommentsCell

        let comment = commentsForPost[indexPath.item]
        cell.configure(with: comment.data)
        cell.representedId = comment.uuid
        
        if let cachedProfileImage = getCachedProfileImage?(comment.uuid as NSUUID) {
            cell.profileImageView?.image = cachedProfileImage
        } else {
            loadProfileImage?(comment.uuid as NSUUID, comment.data.user) { (fetchedImage) in
                DispatchQueue.main.async {
                    guard cell.representedId == comment.uuid else { return }
                    cell.profileImageView?.image = fetchedImage
                }
            }
        }
        return cell
    }
    
    // MARK: Prefetching
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            let comment = self.commentsForPost[$0.item]
            loadProfileImage?(comment.uuid as NSUUID, comment.data.user, nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            let comment = self.commentsForPost[$0.item]
            cancelLoadProfileImage?(comment.uuid as NSUUID)
        }
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
    func didSubmitButtonTapped(_ inputView: CommentInputAccessaryView, with text: String?) {
        guard let currentPostId = currentPostId else { return }
        guard let text = text else {
            inputView.clearTextView()
            return
        }
        
        let submitDate = Date().timeIntervalSince1970
        submitComment?(text, submitDate, currentPostId)

        inputView.clearTextView()
    }
}

extension CommentsViewController: CommentsView {
    func displayComment(_ comment: Comment) {
        commentsForPost.append(CommentObject(comment))
        commentsForPost.sort { (c1, c2) -> Bool in
            let compareResult = c1.data.creationDate.compare(c2.data.creationDate)
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
        dummyCell.textView.setCommentText(username: comment.data.user.username, text: comment.data.text, createdDate: comment.data.creationDate.timeAgoDisplay())
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
        collectionView.register(CommentsCell.nibFromClassName(), forCellWithReuseIdentifier: CommentsCell.reuseId)
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
