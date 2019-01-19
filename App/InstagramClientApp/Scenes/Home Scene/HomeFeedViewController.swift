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
            if let imageUrlString = posts[indexPath.item].imageUrl {
                cell.postImageView.loadImage(from: imageUrlString, using: downloadPostImage)
            }
        }
        
        return cell
    }
    
    // Private Methods

}

extension HomeFeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
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
