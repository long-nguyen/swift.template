//
//  ViewController.swift
//  Template
//
//  Created by Company on 2019/05/27.
//  Copyright © 2019 Active User Co.,LTD. All rights reserved.
//

import UIKit

class SampleViewController: AbstractViewController {
    
    @IBOutlet weak var testBt: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        testBt.setTitle(LSTR("test_Bt"), for: UIControl.State.normal)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tableSegue" {
            LOG("Go here %@ %d", "abc", 1)
        }
    }
}

