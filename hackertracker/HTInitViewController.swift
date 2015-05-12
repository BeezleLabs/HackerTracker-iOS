//
//  HTInitViewController.swift
//  hackertracker
//
//  Created by Seth Law on 3/30/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class HTInitViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let delegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        let fr:NSFetchRequest = NSFetchRequest(entityName:"Status")
        fr.returnsObjectsAsFaults = false
        
        var error:NSError? = nil
        var status : NSArray = context.executeFetchRequest(fr, error: &error)!
        
        if status.count < 1 {
            // First time setup. Let's drop some filler data into the DB for testing. Phase 2: Ask the user to query the DC web service for initial data load.
            
            var now = NSDate()
            
            NSLog("Database not setup, preloading with test data")
            var first_status = NSEntityDescription.insertNewObjectForEntityForName("Status", inManagedObjectContext: context) as! Status
            first_status.lastsync = now
            
            var message1 = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as! Message
            message1.date = now
            message1.value = "Welcome to HackerTracker iOS version 2015"
            
            var message2 = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as! Message
            message2.date = now
            message2.value = "Now with internal CoreData functionality. Rejoice, oh ye of little faith!"
            
            var event1 = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: context) as! Event
            event1.date = now
            event1.name = "Hacker 1"
            event1.title = "Hack all the things"
            event1.details = "How a hacker goes about hacking all the things.\n\nHacker 1 is 31337."
            event1.location = "Track 1"
            event1.starred = false
            event1.start_time = "08:00"
            event1.end_time = "09:00"
            
            var event2 = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: context) as! Event
            event2.date = now
            event2.name = "Defender 1"
            event2.title = "Defending a Django Bango app "
            event2.details = "How to think like a defend and stop a hacker from stealing information out of your glossy new Django app.\nDefender 1 works for the DoD."
            event2.location = "Track 2"
            event2.starred = false
            event2.start_time = "08:00"
            event2.end_time = "09:00"
            
            var event3 = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: context) as! Event
            event3.date = now
            event3.name = "Defender 2"
            event3.title = "Defending a Rails app "
            event3.details = "How to think like a defende and stop a hacker from stealing information out of your outdated Rails app."
            event3.location = "Track 2"
            event3.starred = false
            event3.start_time = "09:00"
            event3.end_time = "10:00"
            
            var event4 = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: context) as! Event
            event4.date = now
            event4.name = "Hacker 2"
            event4.title = "Hack the IoT"
            event4.details = "How a hacker goes about hacking the new Internet of things.\n\nHacker 2 is a network savont."
            event4.location = "Track 1"
            event4.starred = false
            event4.start_time = "09:00"
            event4.end_time = "10:00"
            
            var err:NSError? = nil
            context.save(&err)
            
            if err != nil {
                NSLog("%@",err!)
            }

        }

        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(2), target: self, selector: Selector("go"), userInfo: nil, repeats: false)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func go() {
        self.performSegueWithIdentifier("HTHomeSegue", sender: self)
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
