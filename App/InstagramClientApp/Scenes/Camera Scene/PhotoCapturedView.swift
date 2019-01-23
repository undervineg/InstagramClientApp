//
//  PhotoCapturedView.swift
//  InstagramClientApp
//
//  Created by 심승민 on 23/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class PhotoCapturedView: UIView {
    
    var saveCapturedPhoto: ((Data) -> Void)?

    // MARK: UI Properties
    let capturedImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let cancelButton: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "cancel_shadow"), for: .normal)
        btn.addTarget(self, action: #selector(handleCancel(_:)), for: .touchUpInside)
        return btn
    }()
    
    let saveButton: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "save_shadow"), for: .normal)
        btn.addTarget(self, action: #selector(handleSave(_:)), for: .touchUpInside)
        return btn
    }()
    
    let saveSuccessLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Saved Successfully"
        lb.numberOfLines = 0
        lb.font = UIFont.boldSystemFont(ofSize: 18)
        lb.textAlignment = .center
        lb.textColor = .white
        lb.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
        return lb
    }()
    
    // MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCapturedImageView()
        configureCancelButton()
        configureSaveButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        print("deinit")
    }
    
    // MARK: Actions
    func showSaveSuccessLabel() {
        showSaveLabel()
    }
    
    @objc private func handleCancel(_ sender: UIButton) {
        removeFromSuperview()
    }
    
    @objc private func handleSave(_ sender: UIButton) {
        guard let capturedData = capturedImageView.image?.jpegData(compressionQuality: 0.3) else { return }
        saveCapturedPhoto?(capturedData)
    }
    
    // MAKR: Private Methods
    private func showSaveLabel() {
        saveSuccessLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
        saveSuccessLabel.center = self.center
        addSubview(saveSuccessLabel)
        
        saveSuccessLabel.bounceToAppear {
            self.saveSuccessLabel.bounceToDisappear {
                self.saveSuccessLabel.removeFromSuperview()
            }
        }
    }
    
    private func configureSaveButton() {
        addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -24),
            saveButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            saveButton.widthAnchor.constraint(equalToConstant: 50),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureCancelButton() {
        addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            cancelButton.widthAnchor.constraint(equalToConstant: 50),
            cancelButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureCapturedImageView() {
        addSubview(capturedImageView)
        capturedImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            capturedImageView.topAnchor.constraint(equalTo: topAnchor),
            capturedImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            capturedImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            capturedImageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

extension UILabel {
    func bounceToAppear(_ completion: @escaping () -> Void) {
        self.layer.transform = CATransform3DMakeScale(0, 0, 0)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }) { (completed) in
            completion()
        }
    }
    
    func bounceToDisappear(_ completion: @escaping () -> Void) {
        self.layer.transform = CATransform3DMakeScale(1, 1, 1)
        
        UIView.animate(withDuration: 0.5, delay: 1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
            self.alpha = 0
        }, completion: { (completed) in
            completion()
        })
    }
}
