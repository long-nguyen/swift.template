//
//  CommonUtils.swift
//  Template
//
//  Created by Nguyen Tien LONG on 5/28/19.
//  Copyright © 2019 Active User Co.,LTD. All rights reserved.
//
/*
 Because I'm too familliar with macros in objC, so I convert all of them here
 */

import Foundation
import UIKit

//Log
func LOG(_ items: Any..., separator: String = " ", terminator: String = "\n") {
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

var SCREEN_RECT = UIScreen.main.bounds

