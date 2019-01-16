//
//  SharePhotoViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 16/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

class SharePhotoViewController: UIViewController {
    
    let shareImageView = UIImageView()
    
    private var selectedImage: UIImage?
    
    // MARK: UI Properties
    override var prefersStatusBarHidden: Bool { return true }
    
    convenience init(_ selectedImage: UIImage) {
        self.init()
        self.selectedImage = selectedImage
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        configureNavigationBar()
        configureShareView()
        
        shareImageView.image = selectedImage
    }

    // MARK: Actions
    @objc private func share(_ sender: UIBarButtonItem) {
        
    }
}

extension SharePhotoViewController {
    
    // MARK: Private Methods
    private func configureNavigationBar() {
        navigationController?.navigationBar.tintColor = .black
        
        let shareItem = UIBarButtonItem(title: "Share", style: .done, target: self, action: #selector(share(_:)))
        navigationItem.setRightBarButton(shareItem, animated: true)
    }
    
    private func configureShareView() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 100)
        ])

        shareImageView.contentMode = .scaleAspectFill
        shareImageView.clipsToBounds = true
        containerView.addSubview(shareImageView)
        shareImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shareImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            shareImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            shareImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            shareImageView.widthAnchor.constraint(equalTo: shareImageView.heightAnchor)
        ])
    }
}
