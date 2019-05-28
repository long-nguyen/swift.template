//
//  Sample.swift
//  Template
//
//  Created by Nguyen Tien LONG on 5/28/19.
//  Copyright © 2019 Active User Co.,LTD. All rights reserved.
//

import UIKit
import AlamofireImage

class SampleTableViewController: AbstractTableViewController {
    
    var items = [SampleModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        items = DBHelper.instance.getAllItems()
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = items[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let data = items[indexPath.row]
        cell.textLabel?.text = data.name
        if let url = URL(string: data.imageUrl ?? "") {
            cell.imageView?.af_setImage(withURL: url)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
}
