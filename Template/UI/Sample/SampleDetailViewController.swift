//
//  SampleDetailViewController.swift
//  Template
//
//  Created by Nguyen Tien LONG on 5/28/19.
//  Copyright © 2019 Active User Co.,LTD. All rights reserved.
//

import UIKit
import SDWebImage

class SampleDetailViewController: AbstractViewController {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var detailImg: UIImageView!
    
    var name: String?
    var imageUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLbl.text = name
        if let url = URL(string: imageUrl ?? "") {
            detailImg.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder.png"))
        }
    }
}
