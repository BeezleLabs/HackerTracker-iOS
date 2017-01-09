//
//  HTMyScheduleTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 4/18/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class HTMyScheduleTableViewController: UITableViewController {
    
    var events:NSArray = []
    var selectedEvent : Event?

    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var allButton: UIBarButtonItem!
    @IBOutlet weak var thursdayButton: UIBarButtonItem!
    var isThu:Bool = false
    @IBOutlet weak var fridayButton: UIBarButtonItem!
    var isFri:Bool = false
    @IBOutlet weak var saturdayButton: UIBarButtonItem!
    var isSat:Bool = false
    @IBOutlet weak var sundayButton: UIBarButtonItem!
    var isSun:Bool = false
    @IBOutlet weak var clearButton: UIBarButtonItem!
    
    let highlightColor = UIColor(red: 120/255.0, green: 114/255.0, blue: 255/255.0, alpha: 1)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let font = UIFont(name: "Courier New", size: 12.0) {
            clearButton.setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState())
            allButton.setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState())
            thursdayButton.setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState())
            fridayButton.setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState())
            saturdayButton.setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState())
            sundayButton.setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState())
        }
        
        deHighlightAll()
        
        allButton.tintColor = toolBar.tintColor

        self.clearsSelectionOnViewWillAppear = false

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.isThu {
            filterDay("2016-08-04",button: thursdayButton)
        } else if self.isFri {
            filterDay("2016-08-05",button: fridayButton)
        } else if self.isSat {
            filterDay("2016-08-06",button: saturdayButton)
        } else if self.isSun {
            filterDay("2016-08-07",button: sundayButton)
        } else {

            let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.managedObjectContext!
            
            let fr:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
            fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
            fr.returnsObjectsAsFaults = false
            fr.predicate = NSPredicate(format: "starred == YES", argumentArray: nil)
            self.events = try! context.fetch(fr) as NSArray
            
            self.tableView.reloadData()
        
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.contentInset.top = 22
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func filterThursday(_ sender: AnyObject) {
        let dateString = "2016-08-04"
        isThu = true
        isFri = false
        isSat = false
        isSun = false
        filterDay(dateString,button: thursdayButton)
    }
    @IBAction func filterFriday(_ sender: AnyObject) {
        let dateString = "2016-08-05"
        isThu = false
        isFri = true
        isSat = false
        isSun = false
        filterDay(dateString,button: fridayButton)
    }
    @IBAction func filterSaturday(_ sender: AnyObject) {
        let dateString = "2016-08-06"
        isThu = false
        isFri = false
        isSat = true
        isSun = false
        filterDay(dateString,button: saturdayButton)
    }
    @IBAction func filterSunday(_ sender: AnyObject) {
        let dateString = "2016-08-07"
        isThu = false
        isFri = false
        isSat = false
        isSun = true
        filterDay(dateString,button: sundayButton)
    }
    
    @IBAction func filterAll(_ sender: AnyObject) {
        
        isThu = false
        isFri = false
        isSat = false
        isSun = false
        
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        fr.predicate = NSPredicate(format: "starred == YES", argumentArray: nil)
        fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
        fr.returnsObjectsAsFaults = false
        self.events = try! context.fetch(fr) as NSArray
        
        deHighlightAll()
        allButton.tintColor = toolBar.tintColor
        self.tableView.reloadData()
    }

    
    func deHighlightAll() {
        allButton.tintColor = UIColor.white
        thursdayButton.tintColor = UIColor.white
        fridayButton.tintColor = UIColor.white
        saturdayButton.tintColor = UIColor.white
        sundayButton.tintColor = UIColor.white
        allButton.tintColor = UIColor.white
    }
    
    func filterDay(_ dateString: String,button:UIBarButtonItem) {
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss z"
        df.timeZone = TimeZone(abbreviation: "PDT")
        df.locale = Locale(identifier: "en_US_POSIX")

        let startofDay: Date = df.date(from: "\(dateString) 00:00:00 PDT")!
        let endofDay: Date = df.date(from: "\(dateString) 23:59:59 PDT")!
        
        //NSLog("Getting schedule for \(self.searchTerm)")
        
        let fr:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        fr.predicate = NSPredicate(format: "starred == YES AND begin >= %@ AND end <= %@", argumentArray: [startofDay, endofDay])
        fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
        fr.returnsObjectsAsFaults = false
        self.events = try! context.fetch(fr) as NSArray
        
        deHighlightAll()
        button.tintColor = toolBar.tintColor
        self.tableView.reloadData()
    }

    @IBAction func clearSchedule(_ sender: AnyObject) {
        let alert : UIAlertController = UIAlertController(title: "Clear Schedule", message: "Do you want to clear the viewed events from your schedule?", preferredStyle: UIAlertControllerStyle.alert)
        let yesItem : UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {
            (action:UIAlertAction) in
            var myEv:Event
            let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.managedObjectContext!
            for ev in self.events {
                myEv = ev as! Event
                myEv.starred = false
            }
            var err :NSError?
            do {
                try context.save()
            } catch let error as NSError {
                err = error
            } catch {
                fatalError()
            }
            if err != nil {
                NSLog("%@",err!)
            }
            self.events = []
            self.tableView.reloadData()
            
        })
        let noItem : UIAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: {
            (action:UIAlertAction) in
            NSLog("No")
            //self.tabBarController.selectedIndex = 0
        })
        
        alert.addAction(yesItem)
        alert.addAction(noItem)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.events.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myEventCell", for: indexPath) 

        let event : Event = self.events.object(at: indexPath.row) as! Event
        let df = DateFormatter()
        df.dateFormat = "EE HH:mm"
        df.timeZone = TimeZone(abbreviation: "PDT")
        df.locale = Locale(identifier: "en_US_POSIX")

        let beginDate = df.string(from: event.begin as Date)
        df.dateFormat = "HH:mm"
        let endDate = df.string(from: event.end as Date)
        
        if (event.starred) {
            //NSLog("\(event.title) is starred!")
            cell.textLabel!.text = "** \(event.title) **"
            cell.textLabel!.textColor = self.highlightColor
        } else {
            cell.textLabel!.text = event.title
            cell.textLabel!.textColor = UIColor.white
        }
        cell.detailTextLabel!.text = "\(beginDate)-\(endDate) (\(event.location))"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let myEvent : Event = self.events.object(at: indexPath.row) as! Event
        selectedEvent = myEvent
        self.performSegue(withIdentifier: "myEventDetailSegue", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "myEventDetailSegue") {
            let dv : HTEventDetailViewController = segue.destination as! HTEventDetailViewController
            dv.event = selectedEvent
        }
    }
    

}
