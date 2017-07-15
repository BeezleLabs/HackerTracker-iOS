//
//  HTEventDetailViewController.swift
//  hackertracker
//
//  Created by Seth Law on 4/17/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

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
    @IBOutlet weak var locationMapView: MapLocationView!
    @IBOutlet weak var eventTypeContainer: UIView!
    
    var event: Event?
    
    private let dataRequest = DataRequestManager(managedContext: getContext())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let event = event else {
            print("HTEventDetailViewController: Event is nil")
            return
        }
        
        eventTitleLabel.text = event.title
        
        let speakers : [Speaker]
        
        if let retrievedSpeakers = dataRequest.getSpeakersForEvent(event.index)
        {
            speakers = retrievedSpeakers
        } else {
            speakers = []
        }
        
        eventNameLabel.text = ""
        
        var eventNameText = ""
        
        for s in speakers {
            if (s != speakers.first) {
                eventNameText = eventNameText + ", "
            }
            
            eventNameText = eventNameText + s.who
        }
        
        if speakers.count == 0 {
            eventNameText = "Mystery Speaker"
        }

        eventNameLabel.text = eventNameText
        
        eventLocationLabel.text = event.location
        
        if (event.location.isEmpty) {
            eventLocationLabel.isHidden = true
            locationMapView.isHidden = true
        }
        
        eventDetailTextView.text = event.details
        
        if (event.starred) {
            eventStarredButton.image = #imageLiteral(resourceName: "saved-active")
        } else {
            eventStarredButton.image = #imageLiteral(resourceName: "saved-inactive")
        }
        
        
        toolImage.isHidden = !event.isTool()
        demoImage.isHidden = !event.isDemo()
        exploitImage.isHidden = !event.isExploit()

        eventTypeContainer.isHidden = toolImage.isHidden && demoImage.isHidden && exploitImage.isHidden
        
        let eventLabel = DateFormatterUtility.dayOfWeekMonthTimeFormatter.string(from: event.start_date as Date)
        let eventEnd = DateFormatterUtility.hourMinuteTimeFormatter.string(from: event.end_date as Date)

        eventDateLabel.text = "\(eventLabel)-\(eventEnd)"
        
        locationMapView.currentLocation = Location.valueFromString(event.location)
        
        let touchGesture = UILongPressGestureRecognizer(target: self, action: #selector(mapDetailTapped))
        touchGesture.minimumPressDuration = 0
        locationMapView.addGestureRecognizer(touchGesture)
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
        
        if (event.starred) {
            event.starred = false
            eventStarredButton.image = #imageLiteral(resourceName: "saved-inactive")
            saveContext()
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["hackertracker-\(event.id)"])
        } else {
            
            let _duplicates = dataRequest.findConflictingStarredEvents(event)
            
            if let duplicates = _duplicates, duplicates.count > 0
            {
                let duplicateTitles = duplicates.reduce("", { (result, event) -> String in
                    if result == ""
                    {
                        return "•\'\(event.title)\'"
                    }
                    else
                    {
                        return result + "\n" + "•\'\(event.title)\'"
                    }
                    
                })
                
                let alertBody = "Duplicate event" + (duplicates.count > 1 ? "s" : "") + ":\n" + duplicateTitles +  "\n\nAdd " + "\'\(event.title)\'" + " to schedule?"
                
                let alert : UIAlertController = UIAlertController(title: "Schedule Conflict", message:alertBody, preferredStyle: UIAlertControllerStyle.alert)
                
                let yesItem : UIAlertAction = UIAlertAction(title: "Add Anyway", style: UIAlertActionStyle.default, handler: {
                    (action:UIAlertAction) in
                    event.starred = true
                    self.eventStarredButton.image = #imageLiteral(resourceName: "saved-active")
                    self.saveContext()
                    self.scheduleNotification(at: event.start_date.addingTimeInterval(-600),event)
                })
                
                let noItem : UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler:
                {
                    (action:UIAlertAction) in
                    NSLog("No")
                })
                
                alert.addAction(yesItem)
                alert.addAction(noItem)
                
                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                event.starred = true
                eventStarredButton.image = #imageLiteral(resourceName: "saved-active")
                saveContext()
                scheduleNotification(at: event.start_date.addingTimeInterval(-600),event)
            }
            
        }
    }
    
    func scheduleNotification(at date: Date,_ event:Event) {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)

        
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Event"
        content.body = "\(event.title) in \(event.location)"
        content.sound = UNNotificationSound.default()
        
        let request = UNNotificationRequest(identifier: "hackertracker-\(event.id)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                NSLog("Error: \(error)")
            }
        }

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
    
    func mapDetailTapped(tapGesture : UILongPressGestureRecognizer)
    {
        let touchPoint = tapGesture.location(in: tapGesture.view)
        
        let touchRect = CGRect(origin: touchPoint, size: CGSize(width:1, height:1))
        
        let intersecting = touchRect.intersects(locationMapView.bounds)
        
        locationMapView.alpha = intersecting ? 0.5 : 1.0
        
        switch tapGesture.state {
        case .ended:
            if intersecting {
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let mapView = storyboard.instantiateViewController(withIdentifier: "HTMapsViewController") as! HTMapsViewController
                let navigationController = HTEventsNavViewController(rootViewController: mapView)
                self.present(navigationController, animated: true, completion: nil)
            }
            locationMapView.alpha = 1.0
        case .cancelled, .failed:
            locationMapView.alpha = 1.0
            break
        default:
            break
        }
    }
    
    @IBAction func closeEvent(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
