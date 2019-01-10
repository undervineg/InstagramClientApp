//
//  UserProfileViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 09/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

class UserProfileViewController: UICollectionViewController {

    var loadProfile: (() -> Void)?
    
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        self.init(collectionViewLayout: layout)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        tabBarItem = UITabBarItem(title: "Profile",
                                  image: UIImage(named: "profile_unselected")?.withRenderingMode(.alwaysTemplate),
                                  selectedImage: UIImage(named: "profile_selected")?.withRenderingMode(.alwaysTemplate))
        
        loadProfile?()
    }
}

extension UserProfileViewController: UserProfileView {
    func displayTitle(_ title: String) {
        navigationItem.title = title
    }
    
    func displayError(_ errorMessage: String) {
        let alert = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
