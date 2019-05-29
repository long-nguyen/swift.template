//
//  PopupUtils.swift
//  Template
//
//  Created by Nguyen Tien LONG on 5/28/19.
//  Copyright © 2019 Active User Co.,LTD. All rights reserved.
//

import Foundation
import UIKit

class PopupUtils {
    static func showNetworkError() {
        let alertController = UIAlertController(title: LSTR("err_network_title"), message: LSTR("err_network_msg"), preferredStyle: .alert)
        if let topVC = UIApplication.topViewController() {
            topVC.present(alertController, animated: true, completion: nil)
        }
    }
    
    static func showMessage(message: String?) {
        showMessage(title: nil, message: message)
    }
    
    static func showMessage(title:String?, message: String?) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        if let topVC = UIApplication.topViewController() {
            topVC.present(alertController, animated: true, completion: nil)
        }
    }
    
}
