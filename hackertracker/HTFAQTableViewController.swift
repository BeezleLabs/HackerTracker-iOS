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
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

        cell.textLabel?.text = self.faqs[indexPath.row].question!

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        
        let body = "Q: \(self.faqs[indexPath.row].question!)\n\nA: \(self.faqs[indexPath.row].answer!)"
        
        let messageText = NSMutableAttributedString(
            string: body,
            attributes: [
                NSAttributedStringKey.paragraphStyle: paragraphStyle,
                NSAttributedStringKey.font: UIFont(name: "Larsseit", size: 14),
                NSAttributedStringKey.foregroundColor : UIColor.black
            ]
        )
        
        let popup : UIAlertController = UIAlertController(title: "FAQ", message:"", preferredStyle: UIAlertControllerStyle.alert)
        popup.setValue(messageText, forKey: "attributedMessage")
        
        let doneItem : UIAlertAction = UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: nil)
        popup.addAction(doneItem)
        
        self.present(popup, animated: true, completion: nil)
        //self.present(popup, animated: true) {        }
        
    }
    
    func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */
    
    func loadFAQs() {
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName:"FAQ")
        fr.sortDescriptors = [NSSortDescriptor(key: "updated_at", ascending: false)]
        fr.returnsObjectsAsFaults = false
        
        faqs = try! getContext().fetch(fr) as! [FAQ]
    }

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
