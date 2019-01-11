//
//  UserProfileViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 11/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

private let headerId = "headerId"
private let reuseIdentifier = "Cell"

class UserProfileViewController: UICollectionViewController {
    
    var loadProfile: (() -> Void)?
    var downloadProfileImage: ((URL) -> Void)?
    
    private var userInfo: UserEntity?  = nil {
        didSet {
            navigationItem.title = userInfo?.username
            if let urlString = userInfo?.profileImageUrl, let url = URL(string: urlString) {
                downloadProfileImage?(url)
            }
        }
    }
    
    private var imageData: Data?
    
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
        
        let profileHeaderCellNib = UINib(nibName: "UserProfileHeaderCell", bundle: nil)
        collectionView.register(profileHeaderCellNib,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: headerId)
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadProfile?()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7 
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: headerId,
                                                                     for: indexPath) as! UserProfileHeaderCell
        header.usernameLabel.text = userInfo?.username
        if let data = imageData {
            header.profileImageView.image = UIImage(data: data)
        }
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        cell.backgroundColor = .purple
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
}

extension UserProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (view.frame.width - 2) / 3
        return CGSize(width: w, height: w)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

extension UserProfileViewController: UserProfileView {
    func displayProfileImage(_ imageData: Data) {
        DispatchQueue.main.async {
            self.imageData = imageData
            self.collectionView.reloadData()
        }
    }
    
    func displayUserInfo(_ userInfo: UserEntity) {
        self.userInfo = userInfo
        self.collectionView.reloadData()
    }
    
    func displayError(_ errorMessage: String) {
        let alert = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
