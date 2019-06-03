//
//  String+Ex.swift
//  Template
//
//  Created by Nguyen Tien LONG on 5/28/19.
//  Copyright © 2019 Active User Co.,LTD. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"
        let emailCheck = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailCheck.evaluate(with: self)
    }

    var encodeUrlPercentEncoding: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? self
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
