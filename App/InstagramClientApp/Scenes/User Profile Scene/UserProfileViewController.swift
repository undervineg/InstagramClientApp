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

final class UserProfileViewController: UICollectionViewController {
    // MARK: Commands
    var loadProfile: (() -> Void)?
    var downloadProfileImage: ((URL) -> Void)?
    var logout: (() -> Void)?
    
    // MARK: Router
    private var router: UserProfileRouter.Routes?
    
    // MARK: Model
    private var currentUser: User?  = nil {
        didSet {
            setTitleOnNavigationBar()
            downloadProfileImage(from: currentUser?.profileImageUrl)
        }
    }
    
    private var profileImageData: Data?
    
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
        header.usernameLabel.text = currentUser?.username
        if let data = profileImageData {
            header.profileImageView.image = UIImage(data: data)
        }
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        cell.backgroundColor = .purple
        
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
    func close() {
        router?.openLoginPage()
    }
    
    func displayProfileImage(_ imageData: Data) {
        DispatchQueue.main.async {
            self.profileImageData = imageData
            self.collectionView.reloadData()
        }
    }
    
    func displayUserInfo(_ userInfo: User) {
        self.currentUser = userInfo
        self.collectionView.reloadData()
    }
}

extension UserProfileViewController {
    
    // MARK: Private Methods
    private func downloadProfileImage(from urlString: String?) {
        guard
            let urlString = currentUser?.profileImageUrl,
            let url = URL(string: urlString) else { return }
        downloadProfileImage?(url)
    }
    
    private func configureLogoutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(handleLogout(_:)))
        navigationItem.rightBarButtonItem?.tintColor = .black
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
    
    private func setTitleOnNavigationBar() {
        navigationItem.title = currentUser?.username
    }
    
    private func registerCollectionViewCells() {
        let profileHeaderCellNib = UserProfileHeaderCell.nibFromClassName()
        collectionView.register(profileHeaderCellNib,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: headerId)
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
}
