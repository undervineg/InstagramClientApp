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
    
    // MARK: Commands
    var fetchAllPhotos: ((Int, Bool) -> Void)?
    
    // MARK: Router
    private var router: PhotoSelectorRouter.Routes?
    
    // MARK: Models
    private var images: [UIImage] = []
    private var selectedImage: UIImage?
    
    // MARK: UI Properties
    override var prefersStatusBarHidden: Bool { return true }
    
    // MARK: Initializer
    convenience init(router: PhotoSelectorRouter.Routes) {
        let layout = UICollectionViewFlowLayout()
        self.init(collectionViewLayout: layout)
        self.router = router
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        configureNavigationBar()
        
        self.collectionView.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: cellReuseId)
        self.collectionView.register(PhotoSelectorHeader.self,
                                     forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                     withReuseIdentifier: headerReuseId)
        
        fetchAllPhotos?(50, false)
    }
    
    // MARK: Actions
    @objc private func cancel(_ sender: UIBarButtonItem) {
        router?.closePhotoSelectorPage()
    }
    
    @objc private func next(_ sender: UIBarButtonItem) {
        guard let selectedImage = selectedImage else { return }
        router?.openSharePhotoPage(with: selectedImage)
    }

    // MARK: UICollectionViewDataSource
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

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: headerReuseId,
            for: indexPath
            ) as! PhotoSelectorHeader
        
        headerView.imageView.image = selectedImage
        
        return headerView
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImage = images[indexPath.item]
        collectionView.reloadData()
        
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .bottom, animated: true)
    }

}

extension PhotoSelectorViewController: UICollectionViewDelegateFlowLayout {
    
    // MARK: UICollectionViewDelegateFlowLayout
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
}

extension PhotoSelectorViewController: PhotoSelectorView {
    
    // MARK: PhotoSelectorView
    func displayAllPhotos(_ photoData: Data, _ isAllPhotosFetched: Bool) {
        DispatchQueue.main.async {
            if let image = UIImage(data: photoData) {
                if self.selectedImage == nil {
                    self.selectedImage = image
                }
                self.images.append(image)
            }
            if isAllPhotosFetched {
                self.collectionView.reloadData()
            }
        }
    }

}

extension PhotoSelectorViewController {
    
    // MARK: Private Methods
    private func configureNavigationBar() {
        navigationController?.navigationBar.tintColor = .black
        
        let cancelItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel(_:)))
        let nextItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(next(_:)))
        navigationItem.setLeftBarButton(cancelItem, animated: true)
        navigationItem.setRightBarButton(nextItem, animated: true)
    }
}
