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

class CommentsViewController: UICollectionViewController {
    
    private var currentPost: Post?

    convenience init(currentPost: Post) {
        let layout = UICollectionViewFlowLayout()
        self.init(collectionViewLayout: layout)
        self.currentPost = currentPost
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
    
        
    
        return cell
    }
}
