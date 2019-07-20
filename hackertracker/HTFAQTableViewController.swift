//
//  HTFAQTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 7/12/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit

class HTFAQTableViewController: UITableViewController {

    var faqsToken : UpdateToken?
    var faqs: [HTFAQModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadFAQs()
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
        return faqs.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "faqCell", for: indexPath)

        cell.textLabel?.text = self.faqs[indexPath.row].question

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        
        var body = "Frequently Asked Question Not Found"
        body = "Q: \(self.faqs[indexPath.row].question)\n\nA: \(self.faqs[indexPath.row].answer)"
        
        
        let messageText = NSMutableAttributedString(
            string: body,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body),
                NSAttributedString.Key.foregroundColor : UIColor.black
            ]
        )
        
        let popup : UIAlertController = UIAlertController(title: "FAQ", message:"", preferredStyle: UIAlertController.Style.alert)
        popup.setValue(messageText, forKey: "attributedMessage")
        
        let doneItem : UIAlertAction = UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil)
        popup.addAction(doneItem)
        
        self.present(popup, animated: true, completion: nil)

    }
    
    func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadFAQs() {
        
        faqsToken = FSConferenceDataController.shared.requestFAQs(forConference: AnonymousSession.shared.currentConference, descending: true) { (result) in
            switch result {
            case .success(let faqsList):
                self.faqs = faqsList
                self.tableView.reloadData()
            case .failure(_):
                NSLog("")
            }
        }
    }
    
}
