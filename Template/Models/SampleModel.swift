//
//  SampleModel.swift
//  Template
//
//  Created by Nguyen Tien LONG on 5/28/19.
//  Copyright © 2019 Active User Co.,LTD. All rights reserved.
//

import UIKit

class SampleModel {
    var id: Int64?
    var name: String?
    var imageUrl: String?
    init() {
        //Do nothing
    }
    init(_ name: String!, _ url: String!) {
        self.name = name
        self.imageUrl = url
    }
}
