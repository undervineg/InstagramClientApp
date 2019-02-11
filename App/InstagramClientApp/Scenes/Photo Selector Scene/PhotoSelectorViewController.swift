//
//  PhotoSelectorViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 15/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import InstagramEngine

final class PhotoSelectorViewController: UICollectionViewController, UICollectionViewDataSourcePrefetching {
    // MARK: Commands
    var loadAllPhotos: ((Photo.Order) -> Int)?
    var startCachingPhotos: (([Int], Float, Float) -> Void)?
    var stopCachingPhotos: (([Int]) -> Void)?
    var resetCachedPhotos: (() -> Void)?
    var assetInfo: ((Int) -> PhotoAsset?)?
    var requestImage: ((Int, Float, Float, @escaping (UIImage?) -> Void) -> Void)?
    
    private let order: Photo.Order = .creationDate(.descending)
    private let headerSize: (Float, Float) = (350, 350)
    private var thumbnailSize: (Float, Float) = (0, 0)
    
    // MARK: Router
    private var router: PhotoSelectorRouter.Routes?
    
    // MARK: Models
    private var photosCount: Int?
    private var selectedImage: UIImage?
    
    // MARK: Initializer
    convenience init(router: PhotoSelectorRouter.Routes) {
        let layout = UICollectionViewFlowLayout()
        self.init(collectionViewLayout: layout)
        self.router = router
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetCachedPhotos?()
        
        photosCount = loadAllPhotos?(order)
        
        collectionView.backgroundColor = .white
        
        configureNavigationBar()
        
        collectionView.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: PhotoSelectorCell.reuseId)
        collectionView.register(PhotoSelectorHeader.self,
                                     forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                     withReuseIdentifier: PhotoSelectorHeader.reuseId)
        
        collectionView.isPrefetchingEnabled = true
        collectionView.prefetchDataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let scale = UIScreen.main.scale
        let cellSize = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        thumbnailSize = (Float(cellSize.width * scale), Float(cellSize.height * scale))
    }
    
    // MARK: UICollectionViewDataSourcePrefetching
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let indexes = indexPaths.compactMap { (indexPath) -> Int? in
            return indexPath.item
        }
        startCachingPhotos?(indexes, thumbnailSize.0, thumbnailSize.1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let indexes = indexPaths.compactMap { (indexPath) -> Int? in
            return indexPath.item
        }
        stopCachingPhotos?(indexes)
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosCount ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoSelectorCell.reuseId, for: indexPath) as! PhotoSelectorCell
    
        cell.representedAssetIdentifier = assetInfo?(indexPath.item)?.identifier
        requestImage?(indexPath.item, thumbnailSize.0, thumbnailSize.1) { (image) in
            if cell.representedAssetIdentifier == self.assetInfo?(indexPath.item)?.identifier {
                cell.configure(with: image)
            }
        }
        
        if self.selectedImage == nil {
            requestImage?(indexPath.item, headerSize.0, headerSize.1) { (image) in
                self.selectedImage = image
                collectionView.collectionViewLayout.invalidateLayout()
            }
        }
    
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PhotoSelectorHeader.reuseId,
            for: indexPath
            ) as! PhotoSelectorHeader
        
        headerView.imageView.image = selectedImage
        
        return headerView
    }
    
    // MARK: Actions
    @objc private func cancel(_ sender: UIBarButtonItem) {
        router?.closePhotoSelectorPage()
    }
    
    @objc private func next(_ sender: UIBarButtonItem) {
        guard let selectedImage = selectedImage else { return }
        router?.openSharePhotoPage(with: selectedImage)
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        requestImage?(indexPath.item, headerSize.0, headerSize.1) { (image) in
            self.selectedImage = image
        }
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

extension Array {
    subscript(safe index: Int) -> Element? {
        get {
            return indices.contains(index) ? self[index] : nil
        }
        set {
            if indices.contains(index), let newValue = newValue {
                self.insert(newValue, at: index)
            }
        }
    }
}
