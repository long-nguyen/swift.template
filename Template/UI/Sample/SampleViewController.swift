//
//  ViewController.swift
//  Template
//
//  Created by Company on 2019/05/27.
//  Copyright © 2019 Active User Co.,LTD. All rights reserved.
//

import UIKit
import SwiftyJSON
import JGProgressHUD

class SampleViewController: AbstractViewController {
    
    @IBOutlet weak var testBt: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        testBt.setTitle("test_Bt".localized, for: UIControl.State.normal)
    }
   

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tableSegue" {
            LOG("Go here", "abc", 1)
        }
    }
    @IBAction func onCallAPI(_ sender: Any) {
        APIMng.instance.getSystemInfo {[weak self] (data, error) in
            if let er = error {
                Alerts.showMessage(message: er.message)
            } else if let dt = data {
                self?.updateData(results: dt)
            }
        }
    }
    
    
    func updateData(results: JSON) {
        var members = [SampleModel]()
        for (_, object) in results {
            let item = SampleModel(object as JSON)
            members.append(item)
        }
        
        DatabaseMng.instance.clearAll()
        DatabaseMng.instance.insertItems(items: members)
        var testInsert = DatabaseMng.instance.getAllItems()
        LOG(testInsert.count)
    }
    
    @IBAction func onPurchaseClicked(_ sender: Any) {
        let hud = JGProgressHUD(style: .light)
        hud.show(in: self.view)

        IAPMng.instance.buyProduct(productId: ProductIds.PRO_VERSION) {(result, data, errorMsg) in
            hud.dismiss()
            if (result) {
                Alerts.showMessage(message: "payment_completed".localized)
            } else if errorMsg != nil && errorMsg != PURCHASE_CANCELLED_EVENT {
                Alerts.showMessage(title: "error".localized, message: errorMsg!)
            }
        }
        
    }
    @IBAction func onRestorePurchaseClick(_ sender: Any) {
        let hud = JGProgressHUD(style: .dark)
        hud.show(in: self.view)
        IAPMng.instance.restore { (result, data, errorMsg) in
            hud.dismiss()
            if (result) {
                Alerts.showMessage(message: "payment_restore_completed".localized)
            } else if errorMsg != nil && errorMsg    != PURCHASE_CANCELLED_EVENT {
                Alerts.showMessage(title: "error".localized, message: errorMsg!)
            }
        }
    }
}

