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
    
    var uid: String? = nil
    
    private var isCurrentUser: Bool { return uid == nil }
    private var isFollowing: Bool = false
    
    // MARK: Commands
    var loadProfile: ((String?) -> Void)?
    var loadPosts: ((String?, Post.Order) -> Void)?
    var downloadProfileImage: ((URL, @escaping (Data) -> Void) -> Void)?
    var downloadPostImage: ((URL, @escaping (Data) -> Void) -> Void)?
    var logout: (() -> Void)?
    var editProfile: (() -> Void)?
    var follow: ((String) -> Void)?
    var unfollow: ((String) -> Void)?
    var checkIsFollowing: ((String) -> Void)?
    
    // MARK: Router
    private var router: UserProfileRouter.Routes?
    
    // MARK: Model
    private var user: User?
    private var userPosts: [Post] = []
    
    private var cacheManager: Cacheable?
    
    // MARK: Initializer
    convenience init(router: UserProfileRouter.Routes, cacheManager: Cacheable) {
        let layout = UICollectionViewFlowLayout()
        self.init(collectionViewLayout: layout)
        self.router = router
        self.cacheManager = cacheManager
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = .white
        
        registerCollectionViewCells()
        
        if isCurrentUser {
            configureLogoutButton()
        }
        
        loadProfile?(uid)
        
        if let uid = uid {
            checkIsFollowing?(uid)
        }
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
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: headerId,
                                                                     for: indexPath) as! UserProfileHeader
        headerView.dataSource = self
        headerView.delegate = self
        
        headerView.profileImageView.cacheManager = self.cacheManager
        
        return headerView
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
        
        cell.delegate = self
        
        if userPosts.count > 0 {
            cell.postImageUrl = userPosts[indexPath.item].imageUrl
            cell.imageView.cacheManager = self.cacheManager
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

extension UserProfileViewController: UserProfileView, PostView {
    // MARK: User Profile View
    func onLogoutSucceeded() {
        router?.openLoginPage()
    }
    
    func displayUserInfo(_ userInfo: User) {
        user = userInfo
        setTitleOnNavigationBar()
        collectionView.reloadData()
        
        loadPosts?(uid, .creationDate(.ascending))
    }
    
    func toggleFollowButton(_ isFollowing: Bool) {
        guard !isCurrentUser else { return }
        self.isFollowing = isFollowing
        collectionView.reloadData()
    }
    
    // MARK: Post View
    func displayPost(_ post: Post) {
        userPosts.insert(post, at: 0)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func displayLikes(_ isLike: Bool) {
        //
    }
}

extension UserProfileViewController: UserProfilePhotoCellDelegate {
    func didImageUrlSet(_ userProfileHeaderCell: UserProfilePhotoCell, _ url: URL, _ completion: @escaping (Data) -> Void) {
        downloadPostImage?(url, completion)
    }
}

extension UserProfileViewController: UserProfileHeaderDelegate {
    func didProfileUrlSet(_ userProfileHeaderCell: UserProfileHeader, _ url: URL, _ completion: @escaping (Data) -> Void) {
        downloadProfileImage?(url, completion)
    }
    
    func didTapEditProfileButton(_ userProfileHeaderCell: UserProfileHeader) {
        editProfile?()
    }
    
    func didTapFollowButton(_ userProfileHeaderCell: UserProfileHeader) {
        guard let uid = uid else { return }
        follow?(uid)
    }
    
    func didTapUnfollowButton(_ userProfileHeaderCell: UserProfileHeader) {
        guard let uid = uid else { return }
        unfollow?(uid)
    }
    
    func didTapGridButton(_ userProfileHeaderCell: UserProfileHeader) {
        
    }
    
    func didTapListButton(_ userProfileHeaderCell: UserProfileHeader) {
        
    }
    
    func didTapBookmarkButton(_ userProfileHeaderCell: UserProfileHeader) {
        
    }
}

extension UserProfileViewController: UserProfileHeaderDataSource {
    func username(_ userProfileHeaderCell: UserProfileHeader) -> String? {
        return user?.username
    }
    
    func userProfileUrl(_ userProfileHeaderCell: UserProfileHeader) -> String? {
        return user?.profileImageUrl
    }
    
    func summaryCounts(_ userProfileHeaderCell: UserProfileHeader, _ labelType: UserProfileHeader.SummaryLabelType) -> Int {
        switch labelType {
        case .posts: return userPosts.count
        case .followers: return 0
        case .followings: return 0
        }
    }
    
    func editProfileButtonType(_ userProfileHeaderCell: UserProfileHeader) -> UserProfileHeader.ButtonType {
        var buttonType = UserProfileHeader.ButtonType.edit
        
        if !isCurrentUser && isFollowing {
            buttonType = .unfollow
        } else if !isCurrentUser && !isFollowing {
            buttonType = .follow
        }
        
        return buttonType
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
        navigationItem.title = user?.username
    }
    
    private func registerCollectionViewCells() {
        let profileHeaderCellNib = UserProfileHeader.nibFromClassName()
        collectionView.register(profileHeaderCellNib,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: headerId)
        
        collectionView.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
    }
}
