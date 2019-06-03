//
//  LocalDataMng.swift
//  Template
//
//  Created by Nguyen Tien LONG on 5/28/19.
//  Copyright © 2019 Active User Co.,LTD. All rights reserved.
//

import Foundation

fileprivate let KEY_SAMPLE = "KEY_SAMPLE"
fileprivate let KEY_TOKEN = "KEY_ACCESS_TOKEN"

class PreferenceMng {
    static let instance = PreferenceMng()
    private init() {
        //Do nothing
    }
    
    func reset() {
        sampleVal = 0
        accessToken = nil
    }
    
    var sampleVal: Int {
        get {
            return UserDefaults.standard.integer(forKey: KEY_SAMPLE)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: KEY_SAMPLE)
            UserDefaults.standard.synchronize()
        }
    }
    
    var accessToken: String? {
        get {
            if let token = UserDefaults.standard.string(forKey: KEY_TOKEN) {
                return token
            }
            return nil
        }
        set {
            UserDefaults.standard.set(newValue, forKey: KEY_TOKEN)
            UserDefaults.standard.synchronize()
        }
    }
}
