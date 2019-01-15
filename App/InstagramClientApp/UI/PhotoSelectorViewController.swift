//
//  PhotoSelectorViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 15/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import Photos

private let cellReuseId = "Cell"
private let headerReuseId = "Header"

final class PhotoSelectorViewController: UICollectionViewController {

    private var router: MainRouter.Routes?
    
    var fetchAllPhotos: ((Int, Bool) -> Void)?
    
    private var images: [UIImage] = []
    
    convenience init(router: MainRouter.Routes) {
        let layout = UICollectionViewFlowLayout()
        self.init(collectionViewLayout: layout)
        self.router = router
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .yellow
        
        configureNavigationBar()
        
        self.collectionView.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: cellReuseId)
        self.collectionView.register(UICollectionViewCell.self,
                                     forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                     withReuseIdentifier: headerReuseId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchAllPhotos?(30, false)
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.tintColor = .black
        
        let cancelItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel(_:)))
        let nextItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(next(_:)))
        navigationItem.setLeftBarButton(cancelItem, animated: true)
        navigationItem.setRightBarButton(nextItem, animated: true)
    }
    
    @objc private func cancel(_ sender: UIBarButtonItem) {
        router?.closePhotoSelectorPage()
    }
    
    @objc private func next(_ sender: UIBarButtonItem) {
        
    }

    // MARK: UICollectionViewDataSource

    // Header
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: headerReuseId,
            for: indexPath
        )
        headerView.backgroundColor = .red
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    
    // Cell
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseId, for: indexPath) as! PhotoSelectorCell
    
        if images.count > 0 {
            cell.imageView.image = images[indexPath.item]
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    
}

extension PhotoSelectorViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

extension PhotoSelectorViewController: PhotoSelectorView {
    func displayAllPhotos(_ photoData: Data, _ isAllPhotosFetched: Bool) {
        DispatchQueue.main.async {
            if let image = UIImage(data: photoData) {
                self.images.append(image)
            }
            
            if isAllPhotosFetched {
                self.collectionView.reloadData()
            }
        }
    }

}
