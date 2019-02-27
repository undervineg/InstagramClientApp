//
//  UserSearchViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 20/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

class UserSearchViewController: UICollectionViewController, UICollectionViewDataSourcePrefetching {
    // MARK: UI Properties
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: Commands
    var fetchAllUsers: ((Bool) -> Void)?
    var loadProfileImage: ((NSUUID, User, ((UIImage?) -> Void)?) -> Void)?
    var getCachedProfileImage: ((NSUUID) -> UIImage?)?
    var cancelLoadProfileImage: ((NSUUID) -> Void)?
    
    // MARK: Models
    private var router: UserSearchRouter?
    
    private var users: [UserObject] = []
    private var filteredUsers: [UserObject] = []
    
    // MARK: Initializer
    convenience init(router: UserSearchRouter) {
        let layout = UICollectionViewFlowLayout()
        self.init(collectionViewLayout: layout)
        self.router = router
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        collectionView.isPrefetchingEnabled = true
        collectionView.prefetchDataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Enter username"
        navigationItem.searchController = self.searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        let nib = UserSearchCell.nibFromClassName()
        self.collectionView.register(nib, forCellWithReuseIdentifier: UserSearchCell.reuseId)
        
        fetchAllUsers?(true)
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isFiltering() ? filteredUsers.count : users.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserSearchCell.reuseId, for: indexPath) as! UserSearchCell
        
        if users.count > 0 {
            let user = isFiltering() ? filteredUsers[indexPath.item] : users[indexPath.item]
            cell.usernameLabel.text = user.data.username
            
            if let cachedImage = getCachedProfileImage?(user.uuid as NSUUID) {
                cell.profileImageView.image = cachedImage
            } else {
                loadProfileImage?(user.uuid as NSUUID, user.data) { image in
                    DispatchQueue.main.async {
                        cell.profileImageView.image = image
                    }
                }
            }
        }
        
        return cell
    }
    
    // MARK: Prefetching
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            guard users.count - 1 > $0.item else { return }
            let user = users[$0.item]
            loadProfileImage?(user.uuid as NSUUID, user.data, nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            guard users.count - 1 > $0.item else { return }
            let user = users[$0.item]
            cancelLoadProfileImage?(user.uuid as NSUUID)
        }
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = isFiltering() ? filteredUsers[indexPath.item] : users[indexPath.item]
        router?.openUserProfilePage(of: user.data.id)
    }
    
    @objc private func refresh(_ sender: UIRefreshControl) {
        users.removeAll()
        filteredUsers.removeAll()
        fetchAllUsers?(true)
    }
}

extension UserSearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension UserSearchViewController: SearchView {
    func displayAllUsers(_ loadedUsers: [User]) {
        self.users.append(contentsOf: loadedUsers.map { UserObject($0) })
        
        self.users.sort { (u1, u2) -> Bool in
            return u1.data.username.lowercased().compare(u2.data.username.lowercased()) == .orderedAscending
        }
        
        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
            self.collectionView.reloadData()
        }
    }
}

extension UserSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filterContent(for: searchText)
    }
    
    private func filterContent(for searchText: String) {
        filteredUsers = users.filter { (user) -> Bool in
            return user.data.username.lowercased().contains(searchText.lowercased())
        }
        collectionView.reloadData()
    }
    
    private func isSearchBarEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private func isFiltering() -> Bool {
        return searchController.isActive && !isSearchBarEmpty()
    }
}
