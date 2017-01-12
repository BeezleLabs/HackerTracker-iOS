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
    @IBOutlet weak var demoImage: UIImageView!
    @IBOutlet weak var exploitImage: UIImageView!
    @IBOutlet weak var toolImage: UIImageView!
    
    var event: Event!
    
    let starredButtonTitle = "REMOVE"
    let unstarredButtonTitle = "ADD"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (event != nil) {
            let df = DateFormatter()
            df.dateFormat = "HH:mm"
            df.timeZone = TimeZone(abbreviation: "PDT")
            
            eventTitleLabel.text = event.title
            eventNameButton.setTitle(event.who, for: UIControlState())
            eventLocationLabel.text = event.location
            eventDetailTextView.text = event.details
            
            if (event.starred) {
                eventStarredButton.title = starredButtonTitle
            } else {
                eventStarredButton.title = unstarredButtonTitle
            }
            
            if (event.tool) {
                toolImage.alpha = 1.0
            }
            
            if event.demo {
                demoImage.alpha = 1.0
            }
            
            if event.exploit {
                exploitImage.alpha = 1.0
            }
            
            let df2 : DateFormatter = DateFormatter()
            df2.timeZone = TimeZone(abbreviation: "PDT")
            df2.locale = Locale(identifier: "en_US_POSIX")
            df2.dateFormat = "EEEE, MMMM dd HH:mm"
            
            let eventLabel = NSString(format: "%@",df2.string(from: event.begin as Date)) as String
            let eventEnd = df.string(from: event.end as Date)
            eventDateLabel.text = "\(eventLabel)-\(eventEnd)"
            if let font = UIFont(name: "Courier New", size: 12.0) {
                eventStarredButton.setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState())
            }
            
        } else {
            NSLog("HTEventDetailViewController: Event is nil")
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        eventDetailTextView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        
    }
    
    @IBAction func toggleMySchedule(_ sender: AnyObject) {
        let button = sender as! UIBarButtonItem
        if (event.starred) {
            event.starred = false
            button.title = unstarredButtonTitle
        } else {
            event.starred = true
            button.title = starredButtonTitle
        }
        self.saveContext()
    }
    
    func saveContext() {
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        var err :NSError?
        do {
            try context.save()
        } catch let error as NSError {
            err = error
        }
        if err != nil {
            NSLog("%@",err!)
        }
    }
    
    @IBAction func closeEvent(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
