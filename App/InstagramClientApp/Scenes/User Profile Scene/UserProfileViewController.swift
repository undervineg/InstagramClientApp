//
//  UserProfileViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 11/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

final class UserProfileViewController: UICollectionViewController, UICollectionViewDataSourcePrefetching {
    var uid: String? = nil

    // MARK: Commands
    var loadProfile: ((String?) -> Void)?
    var loadSummaryCounts: ((String?) -> Void)?
    var loadPaginatePosts: ((String?, Any?, Int, Post.Order, Bool) -> Void)?
    
    var loadPostImage: ((NSUUID, Post, ((UIImage?) -> Void)?) -> Void)?
    var getCachedPostImage: ((NSUUID) -> UIImage?)?
    var cancelLoadPostImage: ((NSUUID) -> Void)?
    var loadProfileImage: ((NSUUID, User, ((UIImage?) -> Void)?) -> Void)?
    var getCachedProfileImage: ((NSUUID) -> UIImage?)?
    var cancelLoadProfileImage: ((NSUUID) -> Void)?
    
    var logout: (() -> Void)?
    var editProfile: (() -> Void)?
    var follow: ((String) -> Void)?
    var unfollow: ((String) -> Void)?
    var checkCurrentUserIsFollowing: ((String) -> Void)?

    // MARK: Router
    private var router: UserProfileRouter.Routes?

    // MARK: Model
    private var user: User?
    private var userPosts: [PostObject] = []
    private var userPostsCount: Int = 0

    private let pagingCount: Int = 20
    private let order: Post.Order = .creationDate(.descending)
    private var hasMoreToLoad: Bool = true
    
    private var isCurrentUser: Bool { return uid == nil }
    private var isFollowing: Bool = false
    private var isGridView: Bool = true
    
    private let uuidForHeader = NSUUID()

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

        registerCollectionViewCells()
        setupNotificationsForReloadNewPosts()
        collectionView.isPrefetchingEnabled = true
        collectionView.prefetchDataSource = self

        if isCurrentUser {
            configureLogoutButton()
        }

        loadProfile?(uid)
        loadSummaryCounts?(uid)
        loadPaginatePosts?(uid, nil, pagingCount, order, false)

        if let uid = uid {
            checkCurrentUserIsFollowing?(uid)
        }
    }
    
    // MARK: Prefetching
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            guard userPosts.count - 1 > $0.item else { return }
            let post = userPosts[$0.item]
            loadPostImage?(post.uuid as NSUUID, post.data, nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            guard userPosts.count - 1 > $0.item else { return }
            let post = userPosts[$0.item]
            cancelLoadPostImage?(post.uuid as NSUUID)
        }
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPosts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellId = isGridView ? UserProfileGridCell.reuseId : HomeFeedCell.reuseId
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)

        // Request more data when it's last cell currently
        let isLastCell = indexPath.item == userPosts.count - 1
        if isLastCell && hasMoreToLoad {
            let nextStartingPost = userPosts.last?.data.creationDate.timeIntervalSince1970
            loadPaginatePosts?(uid, nextStartingPost, pagingCount, order, false)
        }
        
        if userPosts.count > 0 {
            let post = userPosts[indexPath.item]

            if let cell = cell as? UserProfileGridCell {
                cell.representedId = post.uuid
                
                if let cachedPostImage = getCachedPostImage?(post.uuid as NSUUID) {
                    cell.imageView.image = cachedPostImage
                } else {
                    loadPostImage?(post.uuid as NSUUID, post.data) { (fetchedImage) in
                        DispatchQueue.main.async {
                            guard cell.representedId == post.uuid else { return }
                            cell.imageView.image = fetchedImage
                        }
                    }
                }
            }

            if let cell = cell as? HomeFeedCell {
                cell.configure(with: post.data)
                cell.representedId = post.uuid
                
                if let cachedPostImage = getCachedPostImage?(post.uuid as NSUUID) {
                    cell.postImageView.image = cachedPostImage
                } else {
                    loadPostImage?(post.uuid as NSUUID, post.data) { (fetchedImage) in
                        DispatchQueue.main.async {
                            guard cell.representedId == post.uuid else { return }
                            cell.postImageView.image = fetchedImage
                        }
                    }
                }
                
                if let cachedProfileImage = getCachedProfileImage?(post.uuid as NSUUID) {
                    cell.profileImageView.image = cachedProfileImage
                } else {
                    loadProfileImage?(post.uuid as NSUUID, post.data.user) { (fetchedImage) in
                        DispatchQueue.main.async {
                            guard cell.representedId == post.uuid else { return }
                            cell.profileImageView.image = fetchedImage
                        }
                    }
                }
            }
        }

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: UserProfileHeader.reuseId,
                                                                         for: indexPath) as! UserProfileHeader
        headerView.dataSource = self
        headerView.delegate = self
        
        if let cachedProfileImage = getCachedProfileImage?(uuidForHeader) {
            headerView.profileImageView.image = cachedProfileImage
        } else if let user = user {
            loadProfileImage?(uuidForHeader, user) { (fetchedImage) in
                DispatchQueue.main.async {
                    headerView.profileImageView.image = fetchedImage
                }
            }
        }
        
        return headerView
    }

    // MARK: Actions
    @objc private func refresh(_ sender: UIRefreshControl) {
        let firstPost = userPosts.first?.data.creationDate.timeIntervalSince1970
        loadPaginatePosts?(uid, firstPost, pagingCount, order.switchSortingForPagination(), true)
        DispatchQueue.main.asyncAfter(deadline: .init(uptimeNanoseconds: 500)) {
            self.loadSummaryCounts?(self.uid)
        }
    }

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
}

extension UserProfileViewController: UserProfileView, PostView {
    // MARK: Post View
    func displayReloadedPosts(_ posts: [Post], hasMoreToLoad: Bool) {
        posts.forEach {
            userPosts.insert(PostObject($0), at: 0)
        }
        self.hasMoreToLoad = hasMoreToLoad
        
        collectionView.reloadData()
    }
    
    func displayPosts(_ posts: [Post?], hasMoreToLoad: Bool) {
        posts.compactMap { $0 }.forEach {
            userPosts.append(PostObject($0))
        }
        self.hasMoreToLoad = hasMoreToLoad
        
        collectionView.reloadData()
    }
    
    func displayPostsCount(_ count: Int) {
        userPostsCount = count
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: User Profile View
    func displayUserInfo(_ userInfo: User) {
        user = userInfo
        setTitleOnNavigationBar()
        collectionView.reloadData()
    }
    
    func toggleFollowButton(_ isFollowing: Bool) {
        guard !isCurrentUser else { return }
        self.isFollowing = isFollowing
        collectionView.reloadData()
    }
    
    func onLogoutSucceeded() {
        router?.openLoginPage()
    }
}

extension UserProfileViewController: UICollectionViewDelegateFlowLayout {
    // MARK: Collection View Delegate Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isGridView {
            let w = (view.frame.width - 2) / 3
            return CGSize(width: w, height: w)
        } else {
            var height: CGFloat = 40 + 8 + 8 // username
            height += view.frame.width       // image
            height += 50                     // buttons
            height += 60                     // caption
            return CGSize(width: view.frame.width, height: height)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

extension UserProfileViewController: UserProfileHeaderDelegate {
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

    func didChangeToGridView(_ userProfileHeaderCell: UserProfileHeader) {
        isGridView = true
        collectionView.reloadData()
    }

    func didChangeToListView(_ userProfileHeaderCell: UserProfileHeader) {
        isGridView = false
        collectionView.reloadData()
    }

    func didTapBookmarkButton(_ userProfileHeaderCell: UserProfileHeader) {

    }
}

extension UserProfileViewController: UserProfileHeaderDataSource {
    func username(_ userProfileHeaderCell: UserProfileHeader) -> String? {
        return user?.username
    }

    func userProfileUrl(_ userProfileHeaderCell: UserProfileHeader) -> String? {
        return user?.imageUrl
    }

    func summaryCounts(_ userProfileHeaderCell: UserProfileHeader, _ labelType: UserProfileHeader.SummaryLabelType) -> Int {
        switch labelType {
        case .posts: return userPostsCount
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
    private func setupNotificationsForReloadNewPosts() {
        NotificationCenter.default.addObserver(self, selector: #selector(refresh(_:)), name: NotificationName.shareNewFeed, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(refresh(_:)), name: NotificationName.followNewUser, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(refresh(_:)), name: NotificationName.unfollowOldUser, object: nil)
    }

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
                                withReuseIdentifier: UserProfileHeader.reuseId)
        collectionView.register(UserProfileGridCell.self, forCellWithReuseIdentifier: UserProfileGridCell.reuseId)
        collectionView.register(HomeFeedCell.nibFromClassName(), forCellWithReuseIdentifier: HomeFeedCell.reuseId)
    }
}
