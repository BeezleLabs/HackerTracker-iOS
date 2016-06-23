//
//  HTUpdatesViewController.swift
//  hackertracker
//
//  Created by Seth Law on 3/30/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class HTUpdatesViewController: UIViewController {

    @IBOutlet weak var updatesTextView: UITextView!
    
    var messages: [Message] = []
    var data = NSMutableData()
    var syncAlert = UIAlertController(title: nil, message: "Syncing...", preferredStyle: .Alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let delegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        let fr:NSFetchRequest = NSFetchRequest(entityName:"Message")
        fr.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        fr.returnsObjectsAsFaults = false
        self.messages = (try! context.executeFetchRequest(fr)) as! [Message]
        
        let df = NSDateFormatter()
        df.timeZone = NSTimeZone(abbreviation: "PDT")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var fullText: String = ""
        for message in messages {
            //var fullDate = df.stringFromDate(message.date)
            fullText = "\(fullText)\(df.stringFromDate(message.date))\n\(message.msg)\n\n"
        }
        
        updatesTextView.font = UIFont(name: "Courier New", size: 14.0)
        updatesTextView.text = fullText
        updatesTextView.textColor = UIColor.whiteColor()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.updatesTextView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    func updateMessages() {
        let delegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        let fr:NSFetchRequest = NSFetchRequest(entityName:"Message")
        fr.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        fr.returnsObjectsAsFaults = false
        self.messages = (try! context.executeFetchRequest(fr)) as! [Message]
        
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var fullText: String = ""
        for message in messages {
            //var fullDate = df.stringFromDate(message.date)
            fullText = "\(fullText)\(df.stringFromDate(message.date))\n\(message.msg)\n\n"
        }
        
        updatesTextView.text = fullText
        updatesTextView.textColor = UIColor.whiteColor()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func syncDatabase(sender: AnyObject) {
        //NSLog("syncDatabase")
        
        let alert : UIAlertController = UIAlertController(title: "Connection Request", message: "Connect to defcon-api for updates?", preferredStyle: UIAlertControllerStyle.Alert)
        let yesItem : UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {
            (action:UIAlertAction) in
            let envPlist = NSBundle.mainBundle().pathForResource("Connections", ofType: "plist")
            let envs = NSDictionary(contentsOfFile: envPlist!)!
            
            self.syncAlert.view.tintColor = UIColor.blackColor()
            let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(10, 5, 50, 50)) as UIActivityIndicatorView
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            loadingIndicator.startAnimating();
            
            self.syncAlert.view.addSubview(loadingIndicator)
            self.presentViewController(self.syncAlert, animated: true, completion: nil)
            
            let tURL = envs.valueForKey("URL") as! String
            //NSLog("Connecting to \(tURL)")
            let URL = NSURL(string: tURL)
            
            let request = NSMutableURLRequest(URL: URL!)
            request.HTTPMethod = "GET"
            
            var queue = NSOperationQueue()
            var con = NSURLConnection(request: request, delegate: self, startImmediately: true)
        })
        let noItem : UIAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: {
            (action:UIAlertAction) in
            NSLog("No")
            //self.tabBarController.selectedIndex = 0
        })
        
        alert.addAction(yesItem)
        alert.addAction(noItem)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func connection(con: NSURLConnection!, didReceiveData _data:NSData!) {
        //NSLog("didReceiveData")
        self.data.appendData(_data)
    }
    
    func connectionDidFinishLoading(con: NSURLConnection!) {
        //NSLog("connectionDidFinishLoading")
        
        let resStr = NSString(data: self.data, encoding: NSASCIIStringEncoding)
        
        //NSLog("response: \(resStr)")

        let dataFromString = resStr!.dataUsingEncoding(NSUTF8StringEncoding)
        
        self.dismissViewControllerAnimated(false, completion: nil)
        updateSchedule(dataFromString!)
        
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let delegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        self.dismissViewControllerAnimated(false, completion: nil)
        
        let failedAlert : UIAlertController = UIAlertController(title: "Connection Failed", message: "Connection to defcon-api failed. Please attempt to sync data later.", preferredStyle: UIAlertControllerStyle.Alert)
        let okItem : UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {
            (action:UIAlertAction) in
                let message2 = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as! Message
                message2.date = NSDate()
                let synctime = df.stringFromDate(message2.date)
                message2.msg = "Update failed."
                var err:NSError? = nil
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
                NSLog("Failed connection to defcon-api. Check network settings.")
                self.updateMessages()
            })
        failedAlert.addAction(okItem)
        self.presentViewController(failedAlert, animated: true, completion: nil)
    }
    
    func updateSchedule(data: NSData) {
        
        let delegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        let json = JSON(data: data, options: NSJSONReadingOptions.AllowFragments, error: nil)
        
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let updateTime = json["updateTime"].string!
        let updateDate = json["updateDate"].string!
        NSLog("schedule updated at \(updateDate) \(updateTime)")
        
        let fr:NSFetchRequest = NSFetchRequest(entityName:"Status")
        let status: Status = (try! context.executeFetchRequest(fr))[0] as! Status
        
        let syncDate = df.dateFromString("\(updateDate) \(updateTime)")! as NSDate
        NSLog("syncDate: \(df.stringFromDate(syncDate)), lastSync: \(df.stringFromDate(status.lastsync))")
        
        var popUpMessage = ""
        
        if ( syncDate.compare(status.lastsync) == NSComparisonResult.OrderedDescending) {
            
            status.lastsync = syncDate
            
            let message2 = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as! Message
            message2.date = syncDate
            message2.msg = "Schedule successfully updated."
            let schedule = json["schedule"].array!
            
            NSLog("Total events: \(schedule.count)")
            
            var mySched : [Event] = []
            
            df.dateFormat = "yyyy-MM-dd HH:mm z"
            
            for item in schedule {
                let fre:NSFetchRequest = NSFetchRequest(entityName:"Event")
                fre.predicate = NSPredicate(format: "id = %@", argumentArray: [item["id"].stringValue])
                var events = try! context.executeFetchRequest(fre)
                var te: Event
                if events.count > 0 {
                    te = events[0] as! Event
                } else {
                    te = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: context) as! Event
                    te.id = item["id"].int32Value
                }
                
                te.who = item["who"].string!
                var d = item["date"].string!
                let b = item["begin"].string!
                let e = item["end"].string!
                if ( d == "" ) {
                    d = "2016-08-04"
                }
                if ( b != "" ) {
                    te.begin = df.dateFromString("\(d) \(b) PDT")!
                } else {
                    te.begin = df.dateFromString("\(d) 00:00 PDT")!
                }
                if ( e != "" ) {
                    te.end = df.dateFromString("\(d) \(e) PDT")!
                } else {
                    te.end = df.dateFromString("\(d) 23:59 PDT")!
                }
                te.location = item["location"].string!
                te.title = item["title"].string!
                if item["description"] != "" {
                    te.details = item["description"].string!
                }
                te.link = item["link"].string!
                te.type = item["type"].string!
                te.demo = item["demo"].boolValue
                te.tool = item["tool"].boolValue
                te.exploit = item["exploit"].boolValue
                te.starred = false
                mySched.append(te)
            }

            
            var err:NSError? = nil
            do {
                try context.save()
            } catch let error as NSError {
                err = error
            }
            
            if err != nil {
                NSLog("%@",err!)
            }
            
            self.updateMessages()

            NSLog("Schedule Updated")
            popUpMessage = "Schedule updated"
        } else {
            NSLog("Schedule is up to date")
            popUpMessage = "Schedule is up to date"
        }

        let updatedAlert : UIAlertController = UIAlertController(title: nil, message: popUpMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let okItem : UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        updatedAlert.addAction(okItem)
        self.presentViewController(updatedAlert, animated: true, completion: nil)
        
        self.data = NSMutableData()
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
