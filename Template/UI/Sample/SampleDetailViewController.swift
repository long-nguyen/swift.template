//
//  SampleDetailViewController.swift
//  Template
//
//  Created by Nguyen Tien LONG on 5/28/19.
//  Copyright © 2019 Active User Co.,LTD. All rights reserved.
//

import UIKit

class SampleDetailViewController: AbstractViewController {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var detailImg: UIImageView!
    
    var name = ""
    var imageUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
