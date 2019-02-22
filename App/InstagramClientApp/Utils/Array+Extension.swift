//
//  Array+Extension.swift
//  InstagramClientApp
//
//  Created by 심승민 on 22/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

extension Array where Element: TextContainer {
    func isAllValid() -> Bool {
        return self.allSatisfy {
            !$0.hasBlanks() && $0.textInside?.count ?? 0 > 0
        }
    }
}
