//
//  SharePhotoViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 16/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

class SharePhotoViewController: UIViewController {
    
    var share: ((Data, String, Float, Float, Double) -> Void)?
    
    let shareImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    
    private var router: SharePhotoRouter.Routes?
    
    private var selectedImage: UIImage?
    
    // MARK: UI Properties
    override var prefersStatusBarHidden: Bool { return true }
    
    convenience init(router: SharePhotoRouter.Routes, selectedImage: UIImage) {
        self.init()
        self.router = router
        self.selectedImage = selectedImage
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        navigationController?.navigationBar.tintColor = .black
        showShareButton()
        configureShareView()
        
        shareImageView.image = selectedImage
    }

    // MARK: Actions
    @objc private func share(_ sender: UIBarButtonItem) {
        guard
            let image = shareImageView.image,
            let imageData = image.jpegData(compressionQuality: 0.3),
            let caption = textView.text, caption.count > 0 else { return }
        
        enableShareButton(false)
        
        let imageWidth = Float(image.size.width)
        let imageHeight = Float(image.size.height)
        let uploadDate = Date().timeIntervalSince1970
        
        view.endEditing(true)
        startIndicatorAnimating()
        share?(imageData, caption, imageWidth, imageHeight, uploadDate)
    }
}

extension SharePhotoViewController: SharePhotoView {
    func displayMain() {
        showShareButton()
        router?.openMainPage()
    }
    
    func displayError(_ errorMessage: String) {
        let alert = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
            self?.showShareButton()
            self?.enableShareButton(true)
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension SharePhotoViewController {
    // MARK: Private Methods
    private func startIndicatorAnimating() {
        let indicatorView = UIActivityIndicatorView(style: .gray)
        let indicatorViewBarItem = UIBarButtonItem(customView: indicatorView)
        navigationItem.setRightBarButton(indicatorViewBarItem, animated: true)
        indicatorView.startAnimating()
    }
    
    private func showShareButton() {
        let shareItem = UIBarButtonItem(title: "공유", style: .done, target: self, action: #selector(share(_:)))
        navigationItem.setRightBarButton(shareItem, animated: true)
    }
    
    private func enableShareButton(_ isEnabled: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = isEnabled
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

        containerView.addSubview(shareImageView)
        shareImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shareImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            shareImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            shareImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            shareImageView.widthAnchor.constraint(equalTo: shareImageView.heightAnchor)
        ])
        
        containerView.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: containerView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: shareImageView.trailingAnchor, constant: 4),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
    }
}
