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
    // Commands
    var loadAllPosts: ((String?) -> Void)?
    var loadFollowerPosts: ((String?) -> Void)?
    var loadPostImage: ((NSUUID, NSString, ((UIImage?) -> Void)?) -> Void)?
    var getCachedPostImage: ((NSUUID) -> UIImage?)?
    var cancelLoadPostImage: ((NSUUID) -> Void)?
    var loadProfileImage: ((NSUUID, NSString, ((UIImage?) -> Void)?) -> Void)?
    var getCachedProfileImage: ((NSUUID) -> UIImage?)?
    var cancelLoadProfileImage: ((NSUUID) -> Void)?
    var changeLikes: ((String, String, Bool, Int) -> Void)?
    
    private var router: HomeFeedRouter.Routes?
    
    // Model
    private var posts: [PostObject] = [] {
        didSet {
            state = (posts.count > 0) ? .loaded : .noData
        }
    }
    
    private var state: PageState = .noData {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.refreshControl?.endRefreshing()
                self.collectionView.reloadData()
            }
        }
    }
    
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
        switch state {
        case .noData: return 1
        case .loaded: return posts.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch state {
        case .noData:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedDefaultCell.reuseId, for: indexPath) as! FeedDefaultCell
//            cell.configure(with: "게시물이 없습니다.")
            return cell
        case .loaded:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeFeedCell.reuseId, for: indexPath) as! HomeFeedCell
            
            if posts.count > indexPath.item {
                let post = posts[indexPath.item]
                cell.configure(with: post)
                cell.representedId = post.uuid
                
                if let cachedPostImage = getCachedPostImage?(post.uuid as NSUUID) {
                    cell.postImageView.image = cachedPostImage
                } else {
                    loadPostImage?(post.uuid as NSUUID, post.data.imageUrl as NSString) { (fetchedImage) in
                        DispatchQueue.main.async {
                            guard cell.representedId == post.uuid else { return }
                            cell.postImageView.image = fetchedImage
                        }
                    }
                }
                
                if let cachedProfileImage = getCachedProfileImage?(post.uuid as NSUUID) {
                    cell.profileImageView.image = cachedProfileImage
                } else {
                    loadProfileImage?(post.uuid as NSUUID, post.user.imageUrl as NSString) { (fetchedImage) in
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
    }
    
    // MARK: Prefetch
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            guard posts.count > $0.item else { return }
            let post = posts[$0.item]
            loadPostImage?(post.uuid as NSUUID, post.data.imageUrl as NSString, nil)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            guard posts.count > $0.item else { return }
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
        switch state {
        case .loaded:
            var height: CGFloat = 40 + 8 + 8 // username
            height += view.frame.width       // image
            height += 50                     // buttons
            height += 60                     // caption
            return CGSize(width: view.frame.width, height: height)
        case .noData:
            var height: CGFloat = view.frame.height
            height -= 20    // status bar
            height -= 44    // navigation bar
            height -= 49    // tab bar
            return CGSize(width: view.frame.width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

extension HomeFeedViewController: HomeFeedCellDelegate {
    func didTapLikeButton(_ cell: HomeFeedCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let currentPost = posts[indexPath.item]
        changeLikes?(currentPost.data.id, currentPost.user.id, !currentPost.hasLiked, indexPath.item)
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
        posts[index].hasLiked = hasLiked
        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }
}

extension HomeFeedViewController: PostView {
    func displayPostObjects(_ loadedPosts: [PostObject], hasMoreToLoad: Bool) {
        loadedPosts.forEach { (loadedPost) in
            let index = (posts.count > 0) ?
                posts.firstIndex { loadedPost.data.creationDate >= $0.data.creationDate } ?? posts.count : 0
            
            posts.insert(loadedPost, at: index)
        }
    }
    
    func displayPostsCount(_ count: Int) { }
    func displayReloadedPosts(_ posts: [PostObject], hasMoreToLoad: Bool) { }
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
        
        collectionView.register(HomeFeedCell.nibFromClassName(), forCellWithReuseIdentifier: HomeFeedCell.reuseId)
        collectionView.register(FeedDefaultCell.self, forCellWithReuseIdentifier: FeedDefaultCell.reuseId)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        let camera = UIBarButtonItem(image: UIImage(named: "camera3"), style: .plain, target: self, action: #selector(openCamera(_:)))
        navigationItem.leftBarButtonItem = camera
        navigationController?.navigationBar.tintColor = .black
    }
}
