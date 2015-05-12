//
//  HTEventDetailViewController.swift
//  hackertracker
//
//  Created by Seth Law on 4/17/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class HTEventDetailViewController: UIViewController {

    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventStartTimeLabel: UILabel!
    @IBOutlet weak var eventStopTimeLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var eventDetailTextView: UITextView!
    @IBOutlet weak var eventStarredButton: UIButton!
    
    var event: Event!
    
    let starredButtonTitle = "Remove from Schedule"
    let unstarredButtonTitle = "Add to Schedule"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (event != nil) {
            eventTitleLabel.text = event.title
            eventNameLabel.text = event.name
            eventStartTimeLabel.text = event.start_time
            eventStopTimeLabel.text = event.end_time
            eventLocationLabel.text = event.location
            eventDetailTextView.text = event.details
            
            if (event.starred == 1) {
                eventStarredButton.setTitle(starredButtonTitle, forState: UIControlState.Normal)
            } else {
                eventStarredButton.setTitle(unstarredButtonTitle, forState: UIControlState.Normal)
            }
            
            var df : NSDateFormatter = NSDateFormatter()
            df.dateFormat = "dd/MM/yyyy"
            
            eventDateLabel.text = NSString(format: "%@",df.stringFromDate(event.date)) as String
        } else {
            NSLog("HTEventDetailViewController: Event is nil")
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleMySchedule(sender: UIButton) {
        NSLog("toggleMySchedule \(event.starred)")
        if (event.starred == 1) {
            event.starred = 0
            sender.setTitle(unstarredButtonTitle, forState: UIControlState.Normal)
        } else {
            event.starred = 1
            sender.setTitle(starredButtonTitle, forState: UIControlState.Normal)
        }
        self.saveContext()
    }
    
    func saveContext() {
        let delegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        var err :NSError?
        context.save(&err)
        if err != nil {
            NSLog("%@",err!)
        }
    }

    @IBAction func closeEvent(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
