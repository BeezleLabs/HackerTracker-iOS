//
//  HTFAQTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 7/12/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class HTFAQTableViewController: UITableViewController {

    var faqs: [FAQ] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadFAQs()
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

        if let q = self.faqs[indexPath.row].question {
            cell.textLabel?.text = q
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        
        var body = "Frequently Asked Question Not Found"
        if let q = self.faqs[indexPath.row].question, let a = self.faqs[indexPath.row].answer {
            body = "Q: \(q)\n\nA: \(a)"
        }
        
        let messageText = NSMutableAttributedString(
            string: body,
            attributes: [
                NSAttributedStringKey.paragraphStyle: paragraphStyle,
                NSAttributedStringKey.font: UIFont(name: "Larsseit", size: 14)!,
                NSAttributedStringKey.foregroundColor : UIColor.black
            ]
        )
        
        let popup : UIAlertController = UIAlertController(title: "FAQ", message:"", preferredStyle: UIAlertControllerStyle.alert)
        popup.setValue(messageText, forKey: "attributedMessage")
        
        let doneItem : UIAlertAction = UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: nil)
        popup.addAction(doneItem)
        
        self.present(popup, animated: true, completion: nil)

    }
    
    func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadFAQs() {
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName:"FAQ")
        fr.sortDescriptors = [NSSortDescriptor(key: "updated_at", ascending: false)]
        fr.returnsObjectsAsFaults = false
        
        faqs = try! getContext().fetch(fr) as! [FAQ]
    }
    
}
