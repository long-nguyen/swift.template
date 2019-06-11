//
//  Sample.swift
//  Template
//
//  Created by Nguyen Tien LONG on 5/28/19.
//  Copyright © 2019 Active User Co.,LTD. All rights reserved.
//

import UIKit
import SDWebImage

class SampleTableViewController: AbstractTableViewController {
    
    var items = [SampleModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        items = DatabaseMng.instance.getAllItems()
        self.tableView.reloadData()
        LOG("Test only")
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = items[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SampleDetailViewController") as! SampleDetailViewController
        controller.name = data.name
        controller.imageUrl = data.imageUrl
        self.navigationController?.pushViewController(controller, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let data = items[indexPath.row]
        cell.textLabel?.text = data.name
        if let url = URL(string: data.imageUrl ?? "") {
            cell.imageView?.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder.png"))
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
}
