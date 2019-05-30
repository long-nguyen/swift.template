//
//  NetworkMng.swift
//  Template
//
//  Created by Nguyen Tien LONG on 5/28/19.
//  Copyright © 2019 Active User Co.,LTD. All rights reserved.
//

import Foundation

class APIMng: APIBase {
    static let instance = APIMng()

    func getSystemInfo(completion: APICompletionHandler?) {
        self.executeRequest(.get, APIPath.config, nil, nil) { (data, error) in
            LOG(data)
        }
    }
}
