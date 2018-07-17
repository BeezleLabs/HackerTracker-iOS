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

protocol EventDetailDelegate {
    func reloadEvents()
}

class HTEventDetailViewController: UIViewController {

    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var eventDetailTextView: UITextView!
    @IBOutlet weak var eventStarredButton: UIBarButtonItem!
    @IBOutlet weak var demoImage: UIImageView!
    @IBOutlet weak var exploitImage: UIImageView!
    @IBOutlet weak var toolImage: UIImageView!
    @IBOutlet weak var locationMapView: MapLocationView!
    @IBOutlet weak var eventTypeContainer: UIView!
    @IBOutlet weak var bottomPaddingConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventTypeLabel: UILabel!
    
    var speakerBios = NSMutableAttributedString(string: "")
    var speakerList = NSMutableAttributedString(string: "")

    var delegate: EventDetailDelegate?
    var event: Event?
    
    private let dataRequest = DataRequestManager(managedContext: getContext())

    /*
    //Keep around for map view visual testing
    var eventLocations : [Location] = [.track_101, .track1_101, .track2, .track2_101, .track3, .track4, .capri, .modena, .trevi, .bioHackingVillage, .cryptoAndPrivacyVillage, .hardwareHackingVillage, .icsVillage, .iotVillage, .lockpickVillage, .packetCaptureVillage, .socialEngineerVillage, .tamperEvidentVillage, .wirelessVillage, .unknown]
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let event = event else {
            print("HTEventDetailViewController: Event is nil")
            return
        }
        
        eventTitleLabel.text = event.title
        
        setupSpeakers(event: event)
        
        eventLocationLabel.text = event.location?.name
        eventTypeLabel.layer.borderColor = UIColor(hexString: (event.event_type?.color!)!).cgColor
        eventTypeLabel.layer.borderWidth = 1.0
        eventTypeLabel.text = " \((event.event_type?.name!)!) "
        eventTypeLabel.layer.masksToBounds = true
        eventTypeLabel.layer.cornerRadius = 5
        
        //locationMapView.isHidden = true
        locationMapView.currentLocation = Location.valueFromString((event.location?.name)!)
        
        eventDetailTextView.text = event.desc

        if (event.starred) {
            eventStarredButton.image = #imageLiteral(resourceName: "saved-active")
        } else {
            eventStarredButton.image = #imageLiteral(resourceName: "saved-inactive")
        }

        toolImage.isHidden = !(event.includes?.lowercased().contains("tool"))!
        demoImage.isHidden = !(event.includes?.lowercased().contains("demo"))!
        exploitImage.isHidden = !(event.includes?.lowercased().contains("exploit"))!

        eventTypeContainer.isHidden = toolImage.isHidden && demoImage.isHidden && exploitImage.isHidden
        
        let eventLabel = DateFormatterUtility.dayOfWeekMonthTimeFormatter.string(from: event.start_date!)
        let eventEnd = DateFormatterUtility.hourMinuteTimeFormatter.string(from: event.end_date!)

        eventDateLabel.text = "\(eventLabel)-\(eventEnd)"
        
        locationMapView.timeOfDay = TimeOfDay.timeOfDay(for: event.start_date!)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.tabBarController == nil
        {
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
            doneButton.tintColor = .white
            navigationItem.leftBarButtonItem = doneButton
        }

        if let splitViewController = self.splitViewController,
            splitViewController.isCollapsed {
            bottomPaddingConstraint.constant = 20
        } else {
            bottomPaddingConstraint.constant = 80
        }
    }
    
    @objc func doneButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        eventDetailTextView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    func setupSpeakers(event : Event) {
        eventNameLabel.textColor = UIColor(red: 79.0/255.0, green: 227.0/255.0, blue: 194.0/255.0, alpha: 1.0)
        
        let speakers = event.speakers?.allObjects as! [Speaker]
        
        eventNameLabel.text = ""
        
        var i = 1
        for s in speakers {
            if (s != speakers.first) {
                speakerList.append(NSAttributedString(string:", "))
            }
            
            speakerList.append(NSAttributedString(string:s.name!))
            
            let whoAttributedString = NSMutableAttributedString(string:s.name!)
            let whoParagraphStyle = NSMutableParagraphStyle()
            whoParagraphStyle.alignment = .center
            whoAttributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: whoParagraphStyle, range: NSRange(location: 0, length: (s.name! as NSString).length))
            whoAttributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: eventNameLabel.textColor, range: NSRange(location: 0, length: (s.name! as NSString).length))
            
            let titleAttributedString = NSMutableAttributedString(string:s.title!)
            let titleParagraphStyle = NSMutableParagraphStyle()
            titleParagraphStyle.alignment = .center
            titleAttributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: titleParagraphStyle, range: NSRange(location: 0, length: (s.title! as NSString).length))
            titleAttributedString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Bungee", size: 14) ?? UIFont.systemFont(ofSize: 14), range: NSRange(location: 0, length: (s.title! as NSString).length))
            titleAttributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: titleParagraphStyle, range: NSRange(location: 0, length: (s.title! as NSString).length))
            
            let bioAttributedString = NSMutableAttributedString(string:s.desc!)
            let bioParagraphStyle = NSMutableParagraphStyle()
            bioParagraphStyle.alignment = .left
            bioAttributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: bioParagraphStyle, range: NSRange(location: 0, length: (s.desc! as NSString).length))
            bioAttributedString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Larsseit", size: 17)!, range: NSRange(location: 0, length: (s.desc! as NSString).length))
            bioAttributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: (s.desc! as NSString).length))
            
            
            speakerBios.append(whoAttributedString)
            speakerBios.append(NSAttributedString(string:"\n"))
            speakerBios.append(titleAttributedString)
            speakerBios.append(NSAttributedString(string:"\n\n"))
            speakerBios.append(bioAttributedString)
            if speakers.count > 1, i < speakers.count {
                speakerBios.append(NSAttributedString(string:"\n\n"))
            }
            i = i+1
        }
        
        let textAttachment = NSTextAttachment()
        textAttachment.image = UIImage(named: "speaker_carrot")
        speakerList.append(NSAttributedString(string:" "))
        speakerList.append(NSAttributedString(attachment:textAttachment))
        
        self.eventNameLabel.contentMode = UIViewContentMode.top
        
        if speakers.count == 0 {
            speakerList = NSMutableAttributedString(string: "Mystery Speaker")
        } else {
            let touchSpeaker = UITapGestureRecognizer(target: self, action: #selector(expand))
            eventNameLabel.isUserInteractionEnabled = true
            eventNameLabel.addGestureRecognizer(touchSpeaker)
        }

        eventNameLabel.attributedText = speakerList
        eventNameLabel.layer.borderColor = UIColor.darkGray.cgColor
        eventNameLabel.layer.borderWidth = 0.5
        eventNameLabel.layer.cornerRadius = 5
        
        
        eventLocationLabel.text = event.location?.name

        locationMapView.currentLocation = Location.valueFromString((event.location?.name)!)
        
        eventDetailTextView.text = event.desc
        
        if (event.starred) {
            eventStarredButton.image = #imageLiteral(resourceName: "saved-active")
        } else {
            eventStarredButton.image = #imageLiteral(resourceName: "saved-inactive")
        }

        toolImage.isHidden = !(event.includes?.lowercased().contains("tool"))!
        demoImage.isHidden = !(event.includes?.lowercased().contains("demo"))!
        exploitImage.isHidden = !(event.includes?.lowercased().contains("exploit"))!

        eventTypeContainer.isHidden = toolImage.isHidden && demoImage.isHidden && exploitImage.isHidden
        
        let eventLabel = DateFormatterUtility.dayOfWeekMonthTimeFormatter.string(from: event.start_date as! Date)
        let eventEnd = DateFormatterUtility.hourMinuteTimeFormatter.string(from: event.end_date as! Date)

        eventDateLabel.text = "\(eventLabel)-\(eventEnd)"
        
        let touchGesture = UILongPressGestureRecognizer(target: self, action: #selector(mapDetailTapped))
        touchGesture.minimumPressDuration = 0.0
        touchGesture.cancelsTouchesInView = false
        locationMapView.addGestureRecognizer(touchGesture)
    }

    @objc func expand() {
        if self.eventNameLabel.attributedText == speakerList {
            self.eventNameLabel.attributedText = speakerBios
        } else {
            self.eventNameLabel.attributedText = speakerList
        }
        
        UIView.animate(withDuration: 0.3) {
           self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func toggleMySchedule(_ sender: AnyObject) {
        guard let event = event else {
            print("HTEventDetailViewController: Event is nil")
            return
        }

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if let error = error {
                print("Request authorization error: \(error.localizedDescription)")
            }
        }
        
        if (event.starred) {
            event.starred = false
            eventStarredButton.image = #imageLiteral(resourceName: "saved-inactive")
            saveContext()
            removeNotification(event)

            reloadEvents()
        } else {
            
            let _duplicates = dataRequest.findConflictingStarredEvents(event)
            
            if let duplicates = _duplicates, duplicates.count > 0
            {
                let duplicateTitles = duplicates.reduce("", { (result, event) -> String in
                    if result == ""
                    {
                        return "• \(event.title!)"
                    }
                    else
                    {
                        return result + "\n" + "• \(event.title!)"
                    }
                    
                })
                
                let alertBody = "Duplicate event" + (duplicates.count > 1 ? "s" : "") + ":\n" + duplicateTitles +  "\n\nAdd " + "\'\(event.title!)\'" + " to schedule?"
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = NSTextAlignment.left
                let messageText = NSMutableAttributedString(
                    string: alertBody,
                    attributes: [
                        NSAttributedStringKey.paragraphStyle: paragraphStyle,
                        NSAttributedStringKey.font: UIFont(name: "Larsseit", size: 14)!,
                        NSAttributedStringKey.foregroundColor : UIColor.black
                    ]
                )
                
                let alert : UIAlertController = UIAlertController(title: "Schedule Conflict", message:"", preferredStyle: UIAlertControllerStyle.alert)
                alert.setValue(messageText, forKey: "attributedMessage")
                
                let yesItem : UIAlertAction = UIAlertAction(title: "Add Anyway", style: UIAlertActionStyle.default, handler: {
                    (action:UIAlertAction) in
                    event.starred = true
                    self.eventStarredButton.image = #imageLiteral(resourceName: "saved-active")
                    self.saveContext()
                    scheduleNotification(at: (event.start_date?.addingTimeInterval(-600))!,event)
                    self.reloadEvents()
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
                scheduleNotification(at: (event.start_date?.addingTimeInterval(-600))!,event)

                reloadEvents()
            }

        }

    }

    func reloadEvents() {
        if let splitViewController = self.splitViewController,
            !splitViewController.isCollapsed {
            delegate?.reloadEvents()
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
    
    @objc func mapDetailTapped(tapGesture : UILongPressGestureRecognizer)
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
                mapView.mapLocation = locationMapView.currentLocation
                mapView.timeOfDay = locationMapView.timeOfDay
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
