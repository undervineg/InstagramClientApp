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
    
    var checkIfAuthenticatedCallback: (() -> Void)?
    
    private var router: SplashRouter.Route?
    
    convenience init(router: SplashRouter.Route) {
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
        
        checkIfAuthenticatedCallback?()
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
        router?.openRegisterPage()
    }
}
