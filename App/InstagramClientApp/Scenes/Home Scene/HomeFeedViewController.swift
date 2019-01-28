//
//  HomeFeedViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 15/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

private let cellId = "cellId"

final class HomeFeedViewController: UICollectionViewController {

    var loadAllPosts: (() -> Void)?
    var downloadPostImage: ((URL, @escaping (Data) -> Void) -> Void)?
    var downloadProfileImage: ((URL, @escaping (Result<Data, UserProfileUseCase.Error>) -> Void) -> Void)?
    var changeLikes: ((String, Bool, Int) -> Void)?
    
    private var router: HomeFeedRouter.Routes?
    
    private var posts: [Post] = []
    private var cacheManager: Cacheable?
    
    convenience init(router: HomeFeedRouter.Routes, cacheManager: Cacheable) {
        let layout = UICollectionViewFlowLayout()
        self.init(collectionViewLayout: layout)
        self.router = router
        self.cacheManager = cacheManager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureExtraUI()
        setupNotificationsForReloadNewPosts()
        loadAllPosts?()
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomeFeedCell
        
        if posts.count > 0 {
            cell.post = posts[indexPath.item]
        }
        
        cell.profileImageView.cacheManager = self.cacheManager
        cell.postImageView.cacheManager = self.cacheManager
        
        cell.delegate = self
        
        return cell
    }
    
    // MARK: Actions
    @objc private func refresh(_ sender: UIRefreshControl) {
        posts.removeAll()
        loadAllPosts?()
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
        let currentPost = posts[indexPath.item]
        changeLikes?(currentPost.id, !currentPost.hasLiked, indexPath.item)
    }
    
    func didTapCommentsButton(_ cell: HomeFeedCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        router?.openCommentsPage(postId: posts[indexPath.item].id)
    }
    
    func didTapSendMeesageButton(_ cell: HomeFeedCell) {
        
    }
    
    func didTapBookMarkButton(_ cell: HomeFeedCell) {
        
    }
    
    func didTapOptionButton(_ cell: HomeFeedCell) {
        
    }
    
    func didProfileImageUrlSet(_ cell: HomeFeedCell, _ url: URL, _ completion: @escaping (Data) -> Void) {
        downloadProfileImage?(url) { (result) in
            switch result {
            case .success(let imageData) : completion(imageData)
            default: return
            }
        }
    }
    
    func didPostImageUrlSet(_ cell: HomeFeedCell, _ url: URL, _ completion: @escaping (Data) -> Void) {
        downloadPostImage?(url, completion)
    }
}

extension HomeFeedViewController: LikesView {
    func displayLikes(_ hasLiked: Bool, at index: Int) {
        posts[index].hasLiked = hasLiked
        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }
}

extension HomeFeedViewController: PostView {
    func displayPost(_ loadedPosts: [Post], hasMoreToLoad: Bool) {
        loadedPosts.forEach { (post) in
            let index = (posts.count > 0) ?
                posts.firstIndex { post.creationDate >= $0.creationDate } ?? posts.count : 0
            
            posts.insert(post, at: index)
            
            DispatchQueue.main.async {
                self.collectionView.refreshControl?.endRefreshing()
                self.collectionView.reloadData()
            }
        }
    }
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
        collectionView.register(nib, forCellWithReuseIdentifier: cellId)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        let camera = UIBarButtonItem(image: UIImage(named: "camera3"), style: .plain, target: self, action: #selector(openCamera(_:)))
        navigationItem.leftBarButtonItem = camera
        navigationController?.navigationBar.tintColor = .black
    }
}
