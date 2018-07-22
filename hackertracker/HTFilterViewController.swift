//
//  HTFilterViewController.swift
//  hackertracker
//
//  Created by Seth Law on 7/15/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit

class HTFilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    var all: [EventType] = []
    var filtered: [EventType] = []
    var delegate: FilterViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        doneButton.layer.borderColor = UIColor.white.cgColor
        doneButton.layer.borderWidth = 1.0
        
        resetButton.layer.borderColor = UIColor.white.cgColor
        resetButton.layer.borderWidth = 1.0

        clearButton.layer.borderColor = UIColor.white.cgColor
        clearButton.layer.borderWidth = 1.0

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.all.count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath)
        
        let et = self.all[indexPath.section]
        if let n = et.name {
            cell.textLabel?.text = n
        }
        cell.layer.borderColor = UIColor(hexString: et.color!).cgColor
        cell.layer.borderWidth = 1.0

        if filtered.contains(et) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let cell = tableView.cellForRow(at: indexPath) {
            let et = self.all[indexPath.section]
            if cell.accessoryType == .checkmark
            {
                cell.accessoryType = .none
                if let index = filtered.index(of: et) {
                    filtered.remove(at: index)
                }
            }
            else
            {
                cell.accessoryType = .checkmark
                filtered.append(et)
            }
        }
    }
    
    @IBAction func resetList(_ sender: Any) {
        filtered = all
        self.tableView.reloadData()
    }
    
    @IBAction func clearList(_ sender: Any) {
        filtered = []
        self.tableView.reloadData()
    }
    
    @IBAction func closePopup(_ sender: Any) {
        delegate?.filterList(filteredEventTypes: filtered)
        dismiss(animated: true, completion: nil)
    }

}

protocol FilterViewControllerDelegate {
    func filterList(filteredEventTypes: [EventType])
}
