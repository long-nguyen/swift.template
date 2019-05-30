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
        
        
        //Test
//        let it1 = SampleModel("Long1", "https://images.pexels.com/photos/414612/pexels-photo-414612.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500")
//        let it2 = SampleModel("Long2", "https://images.pexels.com/photos/248797/pexels-photo-248797.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500")
//        let it3 = SampleModel("Long3", "https://www.w3schools.com/w3css/img_lights.jpg")
//        DatabaseMng.instance.insertItems(items: [it1, it2, it3])
        
        APIMng.instance.getSystemInfo { (data, error) in
            if let res = data {
                LOG(res)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tableSegue" {
            LOG("Go here %@ %d", "abc", 1)
        }
    }
}

