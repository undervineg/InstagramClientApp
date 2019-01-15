//
//  SplashViewController.swift
//  InstagramClientApp
//
//  Created by 심승민 on 10/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
    private let indicatorView = UIActivityIndicatorView(style: .gray)
    
    var checkIfAuthenticated: (() -> Void)?
    
    private var router: SplashRouter.Routes?
    
    convenience init(router: SplashRouter.Routes) {
        self.init()
        self.router = router
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        indicatorView.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkIfAuthenticated?()
    }
    
    private func configureView() {
        // lay indicatorView on the center of the view
        view.addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension SplashViewController: SplashView {
    func displayMain() {
        router?.openMainPage()
    }
    
    func displayRegister() {
        router?.openAuthPage(.login)
    }
}
