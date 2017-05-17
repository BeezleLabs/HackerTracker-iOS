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
    @IBOutlet weak var eventNameButton2: UIButton!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventStartTimeLabel: UILabel!
    @IBOutlet weak var eventStopTimeLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var eventDetailTextView: UITextView!
    @IBOutlet weak var eventStarredButton: UIBarButtonItem!
    @IBOutlet weak var demoImage: UIImageView!
    @IBOutlet weak var exploitImage: UIImageView!
    @IBOutlet weak var toolImage: UIImageView!
    
    var event: Event?
        
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let event = event else {
            print("HTEventDetailViewController: Event is nil")
            return
        }

        eventTitleLabel.text = event.title
        eventNameLabel.text = event.who
        eventLocationLabel.text = event.location
        eventDetailTextView.text = event.details
        
        if (event.starred) {
            eventStarredButton.image = #imageLiteral(resourceName: "saved-active")
        } else {
            eventStarredButton.image = #imageLiteral(resourceName: "saved-inactive")
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

        let eventLabel = DateFormatterUtility.dayOfWeekMonthTimeFormatter.string(from: event.begin as Date)
        let eventEnd = DateFormatterUtility.hourMinuteTimeFormatter.string(from: event.end as Date)

        eventDateLabel.text = "\(eventLabel)-\(eventEnd)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        eventDetailTextView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        
    }
    
    @IBAction func toggleMySchedule(_ sender: AnyObject) {
        guard let event = event else {
            print("HTEventDetailViewController: Event is nil")
            return
        }
        
        let button = sender as! UIBarItem
        if (event.starred) {
            event.starred = false
            button.image = #imageLiteral(resourceName: "saved-inactive")
        } else {
            event.starred = true
            button.image = #imageLiteral(resourceName: "saved-active")
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
