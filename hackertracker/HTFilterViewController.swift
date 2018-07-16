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
    
    var all: [EventType] = []
    var filtered: [EventType] = []
    var delegate: FilterViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        popupView.layer.masksToBounds = true
        popupView.layer.cornerRadius = 5
        doneButton.layer.borderColor = UIColor.white.cgColor
        doneButton.layer.borderWidth = 1.0
        doneButton.layer.masksToBounds = true
        doneButton.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return all.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath)
        
        let et = self.all[indexPath.row]
        cell.textLabel?.text = self.all[indexPath.row].name!
        cell.layer.borderColor = UIColor(hexString: et.color!).cgColor
        cell.layer.borderWidth = 1.0
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 5
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
            let et = self.all[indexPath.row]
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
    
    

    @IBAction func closePopup(_ sender: Any) {
        delegate?.filterList(filteredEventTypes: filtered)
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

protocol FilterViewControllerDelegate {
    func filterList(filteredEventTypes: [EventType])
}
