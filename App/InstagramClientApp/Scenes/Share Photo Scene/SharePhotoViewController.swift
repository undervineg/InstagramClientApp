//
//  SharePhotoViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 16/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

class SharePhotoViewController: UIViewController {

    // MARK: UI Properties
    override var prefersStatusBarHidden: Bool { return true }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .green
        
        configureNavigationBar()
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
}
