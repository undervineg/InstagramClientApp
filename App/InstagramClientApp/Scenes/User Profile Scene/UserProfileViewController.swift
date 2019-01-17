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
private let cellId = "cellId"

final class UserProfileViewController: UICollectionViewController {
    // MARK: Commands
    var loadProfile: (() -> Void)?
    var loadPosts: (() -> Void)?
    var downloadProfileImage: ((URL, @escaping (Data) -> Void) -> Void)?
    var downloadPostImage: ((URL, @escaping (Data) -> Void) -> Void)?
    var logout: (() -> Void)?
    
    // MARK: Router
    private var router: UserProfileRouter.Routes?
    
    // MARK: Model
    private var currentUser: User?
    private var userPosts: [Post] = []
    
    // MARK: Initializer
    convenience init(router: UserProfileRouter.Routes) {
        let layout = UICollectionViewFlowLayout()
        self.init(collectionViewLayout: layout)
        self.router = router
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = .white
        
        configureLogoutButton()
        registerCollectionViewCells()
        
        loadProfile?()
        loadPosts?()
    }

    // MARK: Actions
    @objc private func handleLogout(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            self?.logout?()
        }
        let cancleAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(logoutAction)
        actionSheet.addAction(cancleAction)
        present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPosts.count
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: headerId,
                                                                     for: indexPath) as! UserProfileHeaderCell
        header.usernameLabel.text = currentUser?.username
        
        if let urlString = currentUser?.profileImageUrl {
            header.profileImageView.loadImage(from: urlString, with: downloadProfileImage)
        }
        
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
        
        if userPosts.count > 0 {
            if let urlString = userPosts[indexPath.item].imageUrl {
                cell.imageView.loadImage(from: urlString, with: downloadPostImage)
            }
        }

        return cell
    }
    
}

extension UserProfileViewController: UICollectionViewDelegateFlowLayout {
    
    // MARK: Collection View Delegate Flow Layout
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
    
    // MARK: User Profile View
    func onLogoutSucceeded() {
        router?.openLoginPage()
    }
    
    func displayUserInfo(_ userInfo: User) {
        currentUser = userInfo
        setTitleOnNavigationBar()
        collectionView.reloadData()
    }
    
    func displayPost(_ post: Post) {
        userPosts.insert(post, at: 0)
        collectionView.reloadData()
    }
}

extension UserProfileViewController {
    
    // MARK: Private Methods
    private func configureLogoutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(handleLogout(_:)))
        navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    private func setTitleOnNavigationBar() {
        navigationItem.title = currentUser?.username
    }
    
    private func registerCollectionViewCells() {
        let profileHeaderCellNib = UserProfileHeaderCell.nibFromClassName()
        collectionView.register(profileHeaderCellNib,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: headerId)
        
        collectionView.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
    }
}
