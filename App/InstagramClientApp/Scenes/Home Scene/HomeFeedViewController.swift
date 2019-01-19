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
    
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        self.init(collectionViewLayout: layout)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo2"))
        
        let nib = HomeFeedCell.nibFromClassName()
        collectionView.register(nib, forCellWithReuseIdentifier: cellId)
        
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
            cell.profileImageView.loadImage(from: profileImageUrlString, using: downloadProfileImage)
            
            let imageUrlString = post.imageUrl
            cell.postImageView.loadImage(from: imageUrlString, using: downloadPostImage)
        }
        
        return cell
    }
    
    // Private Methods

}

extension HomeFeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 40 + 8 + 8 // username
        height += view.frame.width       // image
        height += 50                     // buttons
        height += 60                    // caption
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

extension HomeFeedViewController: PostView {
    func displayPost(_ post: Post) {
        posts.insert(post, at: 0)
        collectionView.reloadData()
    }
}
