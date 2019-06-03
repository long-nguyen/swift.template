//
//  PopupUtils.swift
//  Template
//
//  Created by Nguyen Tien LONG on 5/28/19.
//  Copyright © 2019 Active User Co.,LTD. All rights reserved.
//

import Foundation
import UIKit

class Alerts {
    static func showNetworkError() {
        let alertController = UIAlertController(title: "err_network_title".localized, message: "err_network_msg".localized, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))

        if let topVC = UIApplication.topViewController() {
            topVC.present(alertController, animated: true, completion: nil)
        }
    }
    
    static func showMessage(message: String?) {
        showMessage(title: nil, message: message)
    }
    
    static func showMessage(title:String?, message: String?) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
        if let topVC = UIApplication.topViewController() {
            topVC.present(alertController, animated: true, completion: nil)
        }
    }
    
}
