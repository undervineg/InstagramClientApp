//
//  UserSearchViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 20/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

private let cellId = "cellId"

class UserSearchViewController: UICollectionViewController {
    // MARK: UI Properties
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: Commands
    var fetchAllUsers: ((Bool) -> Void)?
    var downloadProfileImage: ((URL, @escaping (Result<Data, UserProfileUseCase.Error>) -> Void) -> Void)?
    
    // MARK: Models
    private var router: UserSearchRouter?
    
    private var users: [User] = []
    private var filteredUsers: [User] = []
    
    private var cacheManager: Cacheable?
    
    // MARK: Initializer
    convenience init(router: UserSearchRouter, cacheManager: Cacheable) {
        let layout = UICollectionViewFlowLayout()
        self.init(collectionViewLayout: layout)
        self.router = router
        self.cacheManager = cacheManager
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Enter username"
        navigationItem.searchController = self.searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        let nib = UserSearchCell.nibFromClassName()
        self.collectionView.register(nib, forCellWithReuseIdentifier: cellId)
        
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserSearchCell
    
        cell.delegate = self
        
        if users.count > 0 {
            let user = isFiltering() ? filteredUsers[indexPath.item] : users[indexPath.item]
            cell.usernameLabel.text = user.username
            
            cell.profileImageUrlString = user.imageUrl
            cell.profileImageView.cacheManager = cacheManager
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = isFiltering() ? filteredUsers[indexPath.item] : users[indexPath.item]
        router?.openUserProfilePage(of: user.id)
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

extension UserSearchViewController: UserSearchCellDelegate {
    func didProfileUrlSet(_ userSearchCell: UserSearchCell, _ url: URL, _ completion: @escaping (Data) -> Void) {
        downloadProfileImage?(url) { (result) in
            switch result {
            case .success(let imageData) : completion(imageData)
            default: return
            }
        }
    }
}

extension UserSearchViewController: SearchView {
    func displayAllUsers(_ users: [User]) {
        self.users = users
        self.users.sort { (u1, u2) -> Bool in
            return u1.username.lowercased().compare(u2.username.lowercased()) == .orderedAscending
        }
        collectionView.reloadData()
    }
}

extension UserSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filterContent(for: searchText)
    }
    
    private func filterContent(for searchText: String) {
        filteredUsers = users.filter { (user) -> Bool in
            return user.username.lowercased().contains(searchText.lowercased())
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
