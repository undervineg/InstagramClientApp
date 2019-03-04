//
//  PhotoCapturedView.swift
//  InstagramClientApp
//
//  Created by 심승민 on 23/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class PhotoCapturedView: UIView, XibLoadable {
    var xibName: String = "PhotoCapturedView"
    
    var saveCapturedPhoto: ((Data) -> Void)?

    // MARK: UI Properties
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var saveSuccessLabel: UILabel!

    // MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromXib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromXib()
    }
    
    deinit {
        print("deinit")
    }
    
    // MARK: Actions
    @IBAction func didTapCancelButton(_ sender: UIButton) {
        removeFromSuperview()
    }
    
    @IBAction func didTapSaveButton(_ sender: UIButton) {
        guard let capturedData = capturedImageView.image?.jpegData(compressionQuality: 0.3) else { return }
        saveCapturedPhoto?(capturedData)
    }
    
    func showSaveSuccessLabel() {
        saveSuccessLabel.isHidden = false
        
        saveSuccessLabel.bounceToAppear {
            self.saveSuccessLabel.bounceToDisappear {
                self.saveSuccessLabel.isHidden = true
            }
        }
    }
}
