//
//  MainTabBarViewControllerTests.swift
//  InstagramClientAppTests
//
//  Created by 심승민 on 09/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
@testable import InstagramClientApp

class MainTabBarViewControllerTests: XCTestCase {

    func test_init_addChildViewControllers() {
        let dummyVCs = [UIViewController(),
                        UIViewController(),
                        UIViewController(),
                        UIViewController()]

        let sut = MainTabBarViewController.init(subViewControllers: dummyVCs)
        
        XCTAssertNotNil(sut.viewControllers)
        XCTAssertEqual(sut.viewControllers, dummyVCs)
    }

    
    // MARK: - Helpers
    
}
