//
//  SampleModel.swift
//  Template
//
//  Created by Nguyen Tien LONG on 5/28/19.
//  Copyright © 2019 Active User Co.,LTD. All rights reserved.
//

import UIKit
import SwiftyJSON

class SampleModel {
    var id: Int64?
    var name: String?
    var imageUrl: String?
    init() {
        //Do neccessary default things
    }
    init(_ name: String!, _ url: String!) {
        self.name = name
        self.imageUrl = url
    }
    convenience init(_ jsonData: JSON) {
        self.init()
        self.id = jsonData["id"].int64Value
        self.name = jsonData["name"].stringValue
        self.imageUrl = jsonData["imageUrl"].stringValue
    }
}
