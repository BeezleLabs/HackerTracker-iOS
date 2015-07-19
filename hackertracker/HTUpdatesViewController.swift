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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let delegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        let fr:NSFetchRequest = NSFetchRequest(entityName:"Message")
        fr.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        fr.returnsObjectsAsFaults = false
        var err:NSError? = nil
        self.messages = context.executeFetchRequest(fr, error: &err) as! [Message]
        
        let df = NSDateFormatter()
        df.dateFormat = "dd/MM/yy"
        var fullText: String = ""
        for message in messages {
            //var fullDate = df.stringFromDate(message.date)
            fullText = "\(fullText)\(df.stringFromDate(message.date))\n\(message.msg)\n\n"
        }
        
        updatesTextView.text = fullText
        updatesTextView.textColor = UIColor.whiteColor()
        
        //self.updatesTextView.text = "Test test test test test"
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func syncDatabase(sender: AnyObject) {
        //NSLog("syncDatabase")
        
        var alert : UIAlertController = UIAlertController(title: "Connection Request", message: "Connect to info.defcon.org for schedule updates?", preferredStyle: UIAlertControllerStyle.Alert)
        var yesItem : UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {
            (action:UIAlertAction!) in
            var envPlist = NSBundle.mainBundle().pathForResource("Connections", ofType: "plist")
            var envs = NSDictionary(contentsOfFile: envPlist!)!
            
            var err:NSError? = nil
            
            var tURL = envs.valueForKey("URL") as! String
            //NSLog("Connecting to \(tURL)")
            var URL = NSURL(string: tURL)
            
            var request = NSMutableURLRequest(URL: URL!)
            request.HTTPMethod = "GET"
            
            var queue = NSOperationQueue()
            var con = NSURLConnection(request: request, delegate: self, startImmediately: true)
        })
        var noItem : UIAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: {
            (action:UIAlertAction!) in
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
        
        var resStr = NSString(data: self.data, encoding: NSASCIIStringEncoding)
        
        //NSLog("response: \(resStr)")

        let dataFromString = resStr!.dataUsingEncoding(NSUTF8StringEncoding)
        
        updateSchedule(dataFromString!)
        
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        var failedAlert : UIAlertController = UIAlertController(title: "Connection Failed", message: "Connection to info.defcon.org failed. Please attempt to sync data later.", preferredStyle: UIAlertControllerStyle.Alert)
        var okItem : UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {
            (action:UIAlertAction!) in
            NSLog("Failed connection to info.defcon.org. Check network settings.")
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
        var status: Status = context.executeFetchRequest(fr, error: nil)![0] as! Status
        
        let syncDate = df.dateFromString("\(updateDate) \(updateTime)")! as NSDate
        NSLog("syncDate: \(df.stringFromDate(syncDate)), lastSync: \(df.stringFromDate(status.lastsync))")
        
        if ( syncDate.compare(status.lastsync) == NSComparisonResult.OrderedDescending) {
            
            status.lastsync = syncDate
            
            var message2 = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as! Message
            message2.date = syncDate
            message2.msg = "Updated \(updateDate) \(updateTime)"
            let schedule = json["schedule"].array!
            
            NSLog("Total events: \(schedule.count)")
            
            var mySched : [Event] = []
            
            df.dateFormat = "yyyy-MM-dd HH:mm"
            
            for item in schedule {
                let fre:NSFetchRequest = NSFetchRequest(entityName:"Event")
                fre.predicate = NSPredicate(format: "id = %@", argumentArray: [item["id"].stringValue])
                var events = context.executeFetchRequest(fre, error: nil)!
                var te: Event
                if events.count > 0 {
                    te = events[0] as! Event
                } else {
                    te = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: context) as! Event
                    te.id = item["id"].int32Value
                }
                
                te.who = item["who"].string!
                let d = item["date"].string!
                let b = item["begin"].string!
                let e = item["end"].string!
                te.begin = df.dateFromString("\(d) \(b)")!
                te.end = df.dateFromString("\(d) \(e)")!
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
            context.save(&err)
            
            if err != nil {
                NSLog("%@",err!)
            }

            NSLog("Schedule Updated")
        } else {
            NSLog("Schedule is up to date")
        }

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
