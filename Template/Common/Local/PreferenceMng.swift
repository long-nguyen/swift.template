//
//  LocalDataMng.swift
//  Template
//
//  Created by Nguyen Tien LONG on 5/28/19.
//  Copyright © 2019 Active User Co.,LTD. All rights reserved.
//

import Foundation

let KEY_START_USING_DAY = "KEY_START_USING_DAY"

class PreferenceMng {
    static let instance = PreferenceMng()
    private init() {
        //Do nothing
    }
    
    var startUsingDay: Int {
        get {
            return UserDefaults.standard.integer(forKey: KEY_START_USING_DAY)
        }
        set(newVal) {
            UserDefaults.standard.set(newVal, forKey: KEY_START_USING_DAY)
        }
    }
}
