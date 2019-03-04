//
//  BasicRouterTests.swift
//  InstagramClientAppTests
//
//  Created by 심승민 on 04/01/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import XCTest
@testable import InstagramClientApp

class BasicRouterTests: XCTestCase {
    
    func test_open_theRightVC() {
        let (sut, stubTransition) = makeSUT()
        
        let openingVC = UIViewController()
        sut.open(openingVC, with: stubTransition)
        
        XCTAssertEqual(stubTransition.openedVC, [openingVC])
    }
    
    func test_openTwice_theRightVCsTwice() {
        let (sut, stubTransition) = makeSUT()
        let root = UIViewController()
        sut.viewController = root
        
        let openingVC1 = UIViewController()
        let openingVC2 = UIViewController()
        sut.open(openingVC1, with: stubTransition)
        sut.open(openingVC2, with: stubTransition)
        
        XCTAssertEqual(stubTransition.openedVC, [openingVC1, openingVC2])
    }
    
    func test_close_theRightVC() {
        let (sut, stubTransition) = makeSUT(isOpening: false)
        let root = UIViewController()
        sut.viewController = root
        
        let closingVC = UIViewController()
        sut.open(closingVC, with: stubTransition)
        
        XCTAssertEqual(stubTransition.openedVC, [closingVC])
        
        sut.close()
        
        XCTAssertEqual(stubTransition.closedVC, [closingVC])
        XCTAssertEqual(stubTransition.openedVC, [])
    }
    
    func test_closeTwice_theRightVCsTwice() {
        let (sut, stubTransition) = makeSUT(isOpening: false)
        let root = UIViewController()
        sut.viewController = root
        
        let closingVC1 = UIViewController()
        let closingVC2 = UIViewController()
        sut.open(closingVC1, with: stubTransition)
        sut.open(closingVC2, with: stubTransition)
        
        XCTAssertEqual(stubTransition.openedVC, [closingVC1, closingVC2])
        
        sut.close()
        sut.close()
        
        XCTAssertEqual(stubTransition.closedVC, [closingVC2, closingVC1])
        XCTAssertEqual(stubTransition.openedVC, [])
    }

    
    // MARK: - Helpers
    
    private func makeSUT(isOpening: Bool = true) -> (sut: BasicRouter, transition: StubTransition) {
        return (BasicRouter(), StubTransition())
    }

}
