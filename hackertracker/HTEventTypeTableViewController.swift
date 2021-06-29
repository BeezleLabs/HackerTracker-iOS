//
//  HTEventTypeTableViewController.swift
//  hackertracker
//
//  Created by Seth W Law on 7/29/20.
//  Copyright © 2020 Beezle Labs. All rights reserved.
//

import UIKit

class HTEventTypeTableViewController: UITableViewController {

    var etToken: UpdateToken?
    var et: [HTEventType] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadETs()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return et.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "etCell", for: indexPath)

        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.text = self.et[indexPath.row].name

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        /*let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        
        var body = "No Category Found"
        body = self.et[indexPath.row].description
        
        
        let messageText = NSMutableAttributedString(
            string: body,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body),
                NSAttributedString.Key.foregroundColor : UIColor.black
            ]
        )
        
        let popup : UIAlertController = UIAlertController(title: self.et[indexPath.row].name, message:"", preferredStyle: UIAlertController.Style.alert)
        popup.setValue(messageText, forKey: "attributedMessage")
        
        let doneItem : UIAlertAction = UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil)
        popup.addAction(doneItem)
        
        self.present(popup, animated: true, completion: nil)*/

    }

    func alertControllerBackgroundTapped() {
        self.dismiss(animated: true, completion: nil)
    }

    func loadETs() {

        etToken = FSConferenceDataController.shared.requestEventTypes(forConference: AnonymousSession.shared.currentConference) { (result) in
            switch result {
            case .success(let etList):
                self.et = etList
                self.tableView.reloadData()
            case .failure(_):
                NSLog("")
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "eventTypeSegue" {
            let etvc: HTEventTypeViewController

            if let destNav = segue.destination as? UINavigationController, let _etvc = destNav.viewControllers.first as? HTEventTypeViewController {
                etvc = _etvc
            } else {
                etvc = segue.destination as! HTEventTypeViewController
            }

            if let indexPath = tableView.indexPathForSelectedRow {
                etvc.event_type = self.et[indexPath.row]
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
            }

        }

    }

}
