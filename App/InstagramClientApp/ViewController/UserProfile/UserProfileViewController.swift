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

    var loadProfile: ((@escaping (Result<UserEntity, UserProfileUseCase.Error>) -> Void) -> ())?
    
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        self.init(collectionViewLayout: layout)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
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
