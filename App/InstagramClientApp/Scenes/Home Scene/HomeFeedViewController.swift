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
    
    private var posts: [Post] = []
    
    private var cacheManager: Cacheable?
    
    convenience init(cacheManager: Cacheable) {
        let layout = UICollectionViewFlowLayout()
        self.init(collectionViewLayout: layout)
        self.cacheManager = cacheManager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo2"))
        
        let nib = HomeFeedCell.nibFromClassName()
        collectionView.register(nib, forCellWithReuseIdentifier: cellId)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        loadAllPosts?()
    }
    
    @objc private func refresh(_ sender: UIRefreshControl) {
        posts.removeAll()
        loadAllPosts?()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomeFeedCell
        
        if posts.count > 0 {
            let post = posts[indexPath.item]
            
            cell.usernameLabel.text = post.user.username
            
            let profileImageUrlString = post.user.profileImageUrl
            cell.profileImageView.cacheManager = self.cacheManager
            cell.profileImageView.loadImage(from: profileImageUrlString, using: downloadProfileImage)
            
            let imageUrlString = post.imageUrl
            cell.postImageView.cacheManager = self.cacheManager
            cell.postImageView.loadImage(from: imageUrlString, using: downloadPostImage)
            
            cell.setAttributedCaptionLabel(username: post.user.username,
                                           caption: post.caption,
                                           createdDate: post.creationDate.timeAgoDisplay())
        }
        
        return cell
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

extension HomeFeedViewController: PostView {
    func displayPost(_ post: Post) {
        let index = (posts.count > 0) ?
            posts.firstIndex { post.creationDate >= $0.creationDate } ?? posts.count : 0
        
        posts.insert(post, at: index)
        
        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
            self.collectionView.reloadData()
        }
    }
}
