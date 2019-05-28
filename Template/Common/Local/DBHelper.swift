//
//  DBHelper.swift
//  Template
//
//  Created by Nguyen Tien LONG on 5/28/19.
//  Copyright © 2019 Active User Co.,LTD. All rights reserved.
//

import Foundation

class DBHelper {
    
    static let instance = DBHelper()
    private init() {
        //Init DB here
    }
    func getAllItems() -> [SampleModel] {
        var items = [SampleModel]()
        return items
    }
}
