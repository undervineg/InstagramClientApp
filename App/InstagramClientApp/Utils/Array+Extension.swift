//
//  Array+Extension.swift
//  InstagramClientApp
//
//  Created by 심승민 on 22/02/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import Foundation

extension Array where Element: TextContainer {
    func isAllValid(shouldCheckBlanksAt canHaveBlanksIndex: Int?) -> Bool {
        guard
            let canHaveBlanksIndex = canHaveBlanksIndex,
            0 <= canHaveBlanksIndex && canHaveBlanksIndex < count - 1 else {
            return self.allSatisfy {
                !$0.hasBlanks() && $0.textInside?.count ?? 0 > 0
            }
        }
        return self.enumerated().allSatisfy { (offset, elem) in
            if offset == canHaveBlanksIndex {
                return elem.textInside?.count ?? 0 > 0
            } else {
                return !elem.hasBlanks() && elem.textInside?.count ?? 0 > 0
            }
        }
    }
}
