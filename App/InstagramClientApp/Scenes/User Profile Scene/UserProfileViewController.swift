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
    
    var loadPostImage: ((NSUUID, NSString, ((UIImage?) -> Void)?) -> Void)?
    var getCachedPostImage: ((NSUUID) -> UIImage?)?
    var cancelLoadPostImage: ((NSUUID) -> Void)?
    var loadProfileImage: ((NSUUID, NSString, ((UIImage?) -> Void)?) -> Void)?
    var getCachedProfileImage: ((NSUUID) -> UIImage?)?
    var cancelLoadProfileImage: ((NSUUID) -> Void)?
    
    var logout: (() -> Void)?
    var editProfile: (() -> Void)?
    var follow: ((String) -> Void)?
    var unfollow: ((String) -> Void)?
    var checkCurrentUserIsFollowing: ((String) -> Void)?
    
    var changeLikes: ((String, String, Bool, Int) -> Void)?

    // MARK: Router
    private var router: UserProfileRouter.Routes?

    // MARK: Model
    private var userPosts: [PostObject] = [] {
        didSet {
            state = (userPosts.count > 0) ? .loaded : .noData
        }
    }
    private var state: PageState = .noData {
        didSet {
            collectionView.refreshControl?.endRefreshing()
            collectionView.reloadData()
        }
    }
    private var user: User? {
        didSet {
            collectionView.refreshControl?.endRefreshing()
            collectionView.reloadData()
        }
    }
    private var userPostsCount: Int = 0 {
        didSet {
            collectionView.refreshControl?.endRefreshing()
            collectionView.reloadData()
        }
    }
    private var isFollowing: Bool = false {
        didSet {
            collectionView.refreshControl?.endRefreshing()
            collectionView.reloadData()
        }
    }
    private var isGridView: Bool = true {
        didSet {
            collectionView.refreshControl?.endRefreshing()
            collectionView.reloadData()
        }
    }
    
    private let pagingCount: Int = 20
    private let order: Post.Order = .creationDate(.descending)
    private var hasMoreToLoad: Bool = true
    
    private var isCurrentUser: Bool { return uid == nil }
    
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

        configureExtraUI()
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
            loadPostImage?(post.uuid as NSUUID, post.data.imageUrl as NSString, nil)
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
        switch state {
        case .noData: return 1
        case .loaded: return userPosts.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch state {
        case .noData:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileDefaultCell.reuseId, for: indexPath) as! ProfileDefaultCell
//            let text = isGridView ? "사진 및 동영상 공유" : "사진과 동영상을 공유하면\n프로필에 표시됩니다."
//            cell.configure(with: text)
            return cell
        case .loaded:
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
                        loadPostImage?(post.uuid as NSUUID, post.data.imageUrl as NSString) { (fetchedImage) in
                            DispatchQueue.main.async {
                                guard cell.representedId == post.uuid else { return }
                                cell.imageView.image = fetchedImage
                            }
                        }
                    }
                }
                
                if let cell = cell as? HomeFeedCell {
                    cell.configure(with: post)
                    cell.representedId = post.uuid
                    
                    if let cachedPostImage = getCachedPostImage?(post.uuid as NSUUID) {
                        cell.postImageView.image = cachedPostImage
                    } else {
                        loadPostImage?(post.uuid as NSUUID, post.data.imageUrl as NSString) { (fetchedImage) in
                            DispatchQueue.main.async {
                                guard cell.representedId == post.uuid else { return }
                                cell.postImageView.image = fetchedImage
                            }
                        }
                    }
                    
                    if let cachedProfileImage = getCachedProfileImage?(post.uuid as NSUUID) {
                        cell.profileImageView.image = cachedProfileImage
                    } else {
                        loadProfileImage?(post.uuid as NSUUID, post.user.imageUrl as NSString) { (fetchedImage) in
                            DispatchQueue.main.async {
                                guard cell.representedId == post.uuid else { return }
                                cell.profileImageView.image = fetchedImage
                            }
                        }
                    }
                }
            }
            
            (cell as? HomeFeedCell)?.delegate = self
            
            return cell
        }
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
            loadProfileImage?(uuidForHeader, user.imageUrl as NSString) { (fetchedImage) in
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
    func displayPostObjects(_ posts: [PostObject], hasMoreToLoad: Bool) {
        posts.compactMap { $0 }.forEach {
            userPosts.append($0)
        }
        self.hasMoreToLoad = hasMoreToLoad
        
        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
            self.collectionView.reloadData()
        }
    }
    
    func displayReloadedPosts(_ posts: [PostObject], hasMoreToLoad: Bool) {
        posts.forEach {
            userPosts.insert($0, at: 0)
        }
        self.hasMoreToLoad = hasMoreToLoad
        
        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
            self.collectionView.reloadData()
        }
    }
    
    func displayPostsCount(_ count: Int) {
        userPostsCount = count
    }
    
    // MARK: User Profile View
    func displayUserInfo(_ userInfo: User) {
        user = userInfo
        setTitleOnNavigationBar()
    }
    
    func toggleFollowButton(_ isFollowing: Bool) {
        guard !isCurrentUser else { return }
        self.isFollowing = isFollowing
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
        switch state {
        case .loaded:
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
        case .noData:
            var height: CGFloat = view.frame.height
            height -= 20    // status bar
            height -= 44    // navigation bar
            height -= 200   // collection view header
            height -= 49    // tab bar
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
    }

    func didChangeToListView(_ userProfileHeaderCell: UserProfileHeader) {
        isGridView = false
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

    private func configureExtraUI() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
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
        collectionView.register(ProfileDefaultCell.self, forCellWithReuseIdentifier: ProfileDefaultCell.reuseId)
    }
}

extension UserProfileViewController: FeedCellDelegate {
    func didTapLikeButton(_ cell: HomeFeedCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let currentPost = userPosts[indexPath.item]
        changeLikes?(currentPost.data.id, currentPost.user.id, !currentPost.hasLiked, indexPath.item)
    }
    
    func didTapCommentsButton(_ cell: HomeFeedCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        router?.openCommentsPage(postId: userPosts[indexPath.item].data.id)
    }
    
    func didTapSendMeesageButton(_ cell: HomeFeedCell) {
        
    }
    
    func didTapBookMarkButton(_ cell: HomeFeedCell) {
        
    }
    
    func didTapOptionButton(_ cell: HomeFeedCell) {
        
    }
}
