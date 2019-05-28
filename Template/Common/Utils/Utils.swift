//
//  CommonUtils.swift
//  Template
//
//  Created by Nguyen Tien LONG on 5/28/19.
//  Copyright © 2019 Active User Co.,LTD. All rights reserved.
//

import Foundation

class Utils {
    static func LOG(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        #if DEBUG
        var idx = items.startIndex
        let endIdx = items.endIndex
        repeat {
            Swift.print(items[idx], separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
            idx += 1
        }
            while idx < endIdx
        #endif
    }
}
