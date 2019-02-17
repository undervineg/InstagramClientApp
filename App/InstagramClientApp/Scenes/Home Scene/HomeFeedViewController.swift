//
//  HomeFeedViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 15/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

final class HomeFeedViewController: UICollectionViewController, UICollectionViewDataSourcePrefetching {
    var loadAllPosts: ((String?) -> Void)?
    var loadFollowerPosts: ((String?) -> Void)?
    var loadPostImage: ((NSUUID, Post, ((UIImage?) -> Void)?) -> Void)?
    var getCachedPostImage: ((NSUUID) -> UIImage?)?
    var cancelLoadPostImage: ((NSUUID) -> Void)?
    var loadProfileImage: ((NSUUID, User, ((UIImage?) -> Void)?) -> Void)?
    var getCachedProfileImage: ((NSUUID) -> UIImage?)?
    var cancelLoadProfileImage: ((NSUUID) -> Void)?
    var changeLikes: ((String, Bool, Int) -> Void)?
    
    private var router: HomeFeedRouter.Routes?
    
    private var posts: [PostObject] = []
    
    convenience init(router: HomeFeedRouter.Routes) {
        let layout = UICollectionViewFlowLayout()
        self.init(collectionViewLayout: layout)
        self.router = router
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureExtraUI()
        setupNotificationsForReloadNewPosts()

        collectionView.isPrefetchingEnabled = true
        collectionView.prefetchDataSource = self
        
        loadAllPosts?(nil)
        loadFollowerPosts?(nil)
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeFeedCell.reuseId, for: indexPath) as! HomeFeedCell

        if posts.count > 0 {
            let post = posts[indexPath.item]
            cell.configure(with: post.data)
            cell.representedId = post.uuid
            
            if let cachedPostImage = getCachedPostImage?(post.uuid as NSUUID) {
                cell.postImageView.image = cachedPostImage
            } else {
                loadPostImage?(post.uuid as NSUUID, post.data) { (fetchedImage) in
                    DispatchQueue.main.async {
                        guard cell.representedId == post.uuid else { return }
                        cell.postImageView.image = fetchedImage
                    }
                }
            }
            
            if let cachedProfileImage = getCachedProfileImage?(post.uuid as NSUUID) {
                cell.profileImageView.image = cachedProfileImage
            } else {
                loadProfileImage?(post.uuid as NSUUID, post.data.user) { (fetchedImage) in
                    DispatchQueue.main.async {
                        guard cell.representedId == post.uuid else { return }
                        cell.profileImageView.image = fetchedImage
                    }
                }
            }
        }
        
        cell.delegate = self
        
        return cell
    }
    
    // MARK: Prefetch
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            guard posts.count - 1 > $0.item else { return }
            let post = posts[$0.item]
            loadPostImage?(post.uuid as NSUUID, post.data, nil)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            guard posts.count - 1 > $0.item else { return }
            let post = posts[$0.item]
            cancelLoadPostImage?(post.uuid as NSUUID)
        }
    }
    
    // MARK: Actions
    @objc private func refresh(_ sender: UIRefreshControl) {
        posts.removeAll()
        loadAllPosts?(nil)
        loadFollowerPosts?(nil)
    }
    
    @objc private func openCamera(_ sender: UIBarButtonItem) {
        let slideTransition = ModalTransition(animator: SlideAnimator())
        router?.openCamera(with: slideTransition)
    }
}

extension HomeFeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 40 + 8 + 8 // username
        height += view.frame.width       // image
        height += 50                     // buttons
        height += 60                     // caption
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

extension HomeFeedViewController: HomeFeedCellDelegate {
    func didTapLikeButton(_ cell: HomeFeedCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let currentPost = posts[indexPath.item].data
        changeLikes?(currentPost.id, !currentPost.hasLiked, indexPath.item)
    }
    
    func didTapCommentsButton(_ cell: HomeFeedCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        router?.openCommentsPage(postId: posts[indexPath.item].data.id)
    }
    
    func didTapSendMeesageButton(_ cell: HomeFeedCell) {
        
    }
    
    func didTapBookMarkButton(_ cell: HomeFeedCell) {
        
    }
    
    func didTapOptionButton(_ cell: HomeFeedCell) {
        
    }
}

extension HomeFeedViewController: LikesView {
    func displayLikes(_ hasLiked: Bool, at index: Int) {
        posts[index].data.hasLiked = hasLiked
        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }
}

extension HomeFeedViewController: PostView {
    func displayPosts(_ loadedPosts: [Post?], hasMoreToLoad: Bool) {
        loadedPosts.forEach { (loadedPost) in
            guard let loadedPost = loadedPost else { return }
            let index = (posts.count > 0) ?
                posts.firstIndex { loadedPost.creationDate >= $0.data.creationDate } ?? posts.count : 0
            posts.insert(PostObject(loadedPost), at: index)
        }

        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
            self.collectionView.reloadData()
        }
    }
    
    func displayPostsCount(_ count: Int) { }
    func displayReloadedPosts(_ posts: [Post], hasMoreToLoad: Bool) { }
}

extension HomeFeedViewController {
    //MARK: Private Methods
    private func setupNotificationsForReloadNewPosts() {
        NotificationCenter.default.addObserver(self, selector: #selector(refresh(_:)), name: NotificationName.shareNewFeed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh(_:)), name: NotificationName.followNewUser, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh(_:)), name: NotificationName.unfollowOldUser, object: nil)
    }
    
    private func configureExtraUI() {
        collectionView.backgroundColor = .white
        
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo2"))
        
        let nib = HomeFeedCell.nibFromClassName()
        collectionView.register(nib, forCellWithReuseIdentifier: HomeFeedCell.reuseId)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        let camera = UIBarButtonItem(image: UIImage(named: "camera3"), style: .plain, target: self, action: #selector(openCamera(_:)))
        navigationItem.leftBarButtonItem = camera
        navigationController?.navigationBar.tintColor = .black
    }
}
