//
//  HTHamburgerMenuTableViewController.swift
//  hackertracker
//
//  Created by Christopher Mays on 7/28/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit

protocol HTHamburgerMenuTableViewControllerDelegate : class {
    func didSelectItem(item: HamburgerItem)
}

class HTHamburgerMenuTableViewController: UITableViewController {

    weak var delegate : HTHamburgerMenuTableViewControllerDelegate?
    let items : [HamburgerItem]
    var selectedItem : HamburgerItem?
    var conferenceName : String?
  
    init(hamburgerItems : [HamburgerItem]) {
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        conferenceName = DataRequestManager(managedContext: context).getSelectedConference()?.name
        
        items = hamburgerItems
        super.init(style: UITableViewStyle.plain)
        tableView.estimatedRowHeight = 254
        
        tableView.register(UINib(nibName:"HTHamburgerHeaderTableViewCell", bundle:nil), forCellReuseIdentifier: "Header")
        tableView.register(UINib(nibName:"HTHamburgerItemTableViewCell", bundle:nil), forCellReuseIdentifier: "ItemCell")
    }
    
    func setSelectedItem(hamburgerItem : HamburgerItem) {
        selectedItem = hamburgerItem
        guard let index = items.index(where: { (item) -> Bool in
            return item == hamburgerItem
        }) else {
            return;
        }
        
        tableView.selectRow(at: IndexPath(row: index + 1, section: 0), animated:false, scrollPosition:.none)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.backgroundGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedItem = selectedItem {
            setSelectedItem(hamburgerItem: selectedItem)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Header") as! HTHamburgerHeaderTableViewCell
            cell.conferenceTitle.text = conferenceName
            return cell;
        } else {
            let currentItem = items[indexPath.row - 1]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") as! HTHamburgerItemTableViewCell
            cell.titleLabel.text = currentItem.title
            
            if let image = UIImage(named: currentItem.imageID) {
                cell.iconView.image = image;
            } else {
                cell.iconView.image = nil
            }
            
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count + 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0 ) {
            return
        }
        
        delegate?.didSelectItem(item: items[indexPath.row - 1])
    }
}
