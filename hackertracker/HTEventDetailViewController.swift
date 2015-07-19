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
    @IBOutlet weak var eventNameButton: UIButton!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventStartTimeLabel: UILabel!
    @IBOutlet weak var eventStopTimeLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var eventDetailTextView: UITextView!
    @IBOutlet weak var eventStarredButton: UIBarButtonItem!
    
    var event: Event!
    
    let starredButtonTitle = "-"
    let unstarredButtonTitle = "+"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (event != nil) {
            let df = NSDateFormatter()
            df.dateFormat = "HH:mm"
            
            eventTitleLabel.text = event.title
            eventNameButton.setTitle(event.who, forState: UIControlState.Normal)
            eventStartTimeLabel.text = df.stringFromDate(event.begin)
            eventStopTimeLabel.text = df.stringFromDate(event.end)
            eventLocationLabel.text = event.location
            eventDetailTextView.text = event.details //.stringByReplacingOccurrencesOfString("<.*?>", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
            //eventDetailTextView.text.stringByReplacingOccurrencesOfString("\n", withString: <#String#>, options: <#NSStringCompareOptions#>, range: <#Range<String.Index>?#>)
            
            if (event.starred) {
                eventStarredButton.title = starredButtonTitle
            } else {
                eventStarredButton.title = unstarredButtonTitle
            }
            
            var df2 : NSDateFormatter = NSDateFormatter()
            df2.dateFormat = "EEEE, MMMM dd"
            
            eventDateLabel.text = NSString(format: "%@",df2.stringFromDate(event.begin)) as String
        } else {
            NSLog("HTEventDetailViewController: Event is nil")
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        eventDetailTextView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleMySchedule(sender: AnyObject) {
        //NSLog("toggleMySchedule \(event.starred)")
        var button = sender as! UIBarButtonItem
        if (event.starred) {
            event.starred = false
            button.title = unstarredButtonTitle
            //sender.setTitle(unstarredButtonTitle, forState: UIControlState.Normal)
        } else {
            event.starred = true
            button.title = starredButtonTitle
            //sender.setTitle(starredButtonTitle, forState: UIControlState.Normal)
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
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Pass the selected object to the new view controller.
    }*/

}
