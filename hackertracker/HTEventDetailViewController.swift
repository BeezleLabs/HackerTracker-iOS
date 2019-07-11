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
import SafariServices

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
    @IBOutlet weak var eventTypeContainer: UIStackView!
    @IBOutlet weak var bottomPaddingConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventTypeLabel: UILabel!
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var twitterStackView: UIStackView!
    
    var speakerBios = NSMutableAttributedString(string: "")
    var speakerList = NSMutableAttributedString(string: "")

    var delegate: EventDetailDelegate?
    var event: HTEventModel?
    var speakers: [HTSpeaker] = []
    var speakerTokens : [UpdateToken<HTSpeaker>] = []
    var myCon: ConferenceModel?
    var eventToken : UpdateToken<HTEventModel>?
    
    private let dataRequest = DataRequestManager(managedContext: getContext())

    /*
    //Keep around for map view visual testing
    var eventLocations : [Location] = [.track_101, .track1_101, .track2, .track2_101, .track3, .track4, .capri, .modena, .trevi, .bioHackingVillage, .cryptoAndPrivacyVillage, .hardwareHackingVillage, .icsVillage, .iotVillage, .lockpickVillage, .packetCaptureVillage, .socialEngineerVillage, .tamperEvidentVillage, .wirelessVillage, .unknown]
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let _ = eventToken {
            loadEvent()
        } else {
            eventToken = FSConferenceDataController.shared.requestEvents(forConference: AnonymousSession.shared.currentConference, eventId: event!.id) { (result) in
                switch result {
                case .success(let retEvent):
                    self.event = retEvent
                    self.loadEvent()
                case .failure(let _):
                    NSLog("")
                }
            }
        }
        
    }
    
    func loadEvent() {
        guard let event = event else {
            print("HTEventDetailViewController: Event is nil")
            return
        }
        
        twitterStackView.translatesAutoresizingMaskIntoConstraints = false
        
        twitterStackView.isHidden = true
        
        eventTitleLabel.text = event.title
        
        getSpeakers()
        setupSpeakerNames()
        
        eventLocationLabel.text = event.location.name
        
        eventTypeLabel.layer.borderColor = UIColor(hexString: event.type.color).cgColor
        eventTypeLabel.layer.backgroundColor = UIColor(hexString: event.type.color).cgColor
        
        eventTypeLabel.layer.borderWidth = 1.0
        eventTypeLabel.text = " \(event.type.name) "
        
        eventTypeLabel.layer.masksToBounds = true
        eventTypeLabel.layer.cornerRadius = 5
        
        
        /*if let l = event.location, let n = l.name {
         locationMapView.currentLocation = Location.valueFromString(n)
         } else {
         locationMapView.currentLocation = .unknown
         }
         locationMapView.setup()*/
        
        eventDetailTextView.text = event.description
        
        /*if (event.starred) {
         eventStarredButton.image = #imageLiteral(resourceName: "star_active")
         } else {
         eventStarredButton.image = #imageLiteral(resourceName: "star_inactive")
         }*/
        
        let i = event.includes
        if !i.lowercased().contains("tool") { toolImage.isHidden = true }
        if !i.lowercased().contains("demo") { demoImage.isHidden = true }
        if !i.lowercased().contains("exploit") { exploitImage.isHidden = true }
        if i != "" {
            if let t = eventDetailTextView.text {
                eventDetailTextView.text = "\(t)\n\nIncludes: \(i.uppercased())"
            }
        }
        
        if event.links == "" {
            linkButton.isHidden = true
            linkButton.isEnabled = false
        } else {
            linkButton.isEnabled = true
        }
        
        eventTypeContainer.isHidden = toolImage.isHidden && demoImage.isHidden && exploitImage.isHidden && linkButton.isHidden
        
        let dfu = DateFormatterUtility.shared
        let eventLabel = dfu.shortDayMonthDayTimeOfWeekFormatter.string(from: event.beginDate)
        var eventEnd = ""
        if Calendar.current.isDate(event.endDate, inSameDayAs: event.beginDate) {
            eventEnd = dfu.hourMinuteTimeFormatter.string(from: event.endDate)
        } else {
            eventEnd = dfu.dayOfWeekTimeFormatter.string(from: event.endDate)
        }
        eventDateLabel.text = "\(eventLabel)-\(eventEnd)"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyDoneButtonIfNeeded()
        if let splitViewController = self.splitViewController,
            splitViewController.isCollapsed {
            bottomPaddingConstraint.constant = 20
        } else {
            bottomPaddingConstraint.constant = 80
        }
    }
    
    func applyDoneButtonIfNeeded() {
        guard let _ = self.navigationController?.parent as? HTHamburgerMenuViewController else {
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
            doneButton.tintColor = .white
            navigationItem.rightBarButtonItem = doneButton
            return
        }
    }
    
    @objc func doneButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        eventDetailTextView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    func getSpeakers() {
        
        for s in event!.speakers {
            let sToken = FSConferenceDataController.shared.requestSpeaker(forConference: AnonymousSession.shared.currentConference, speakerId: s.id) { (result) in
                switch result {
                case .success(let speaker):
                    self.speakers.append(speaker)
                case .failure(let _):
                    NSLog("")
                }
            }
            speakerTokens.append(sToken)
        }
        
    }
    
    func setupSpeakerNames() {
        eventNameLabel.textColor = UIColor(hexString: "#98b7e1")
        
        eventNameLabel.text = ""
        for s in event!.speakers {
            if (s.id != event!.speakers.first!.id) {
                speakerList.append(NSAttributedString(string:", "))
            }
            let whoAttributedString = NSMutableAttributedString(string:s.name)
            let whoParagraphStyle = NSMutableParagraphStyle()
            whoParagraphStyle.alignment = .left
            whoAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: whoParagraphStyle, range: NSRange(location: 0, length: (s.name as NSString).length))
            whoAttributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Bungee", size: 17) ?? UIFont.systemFont(ofSize: 17), range: NSRange(location: 0, length: (s.name as NSString).length))
            whoAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: eventNameLabel.textColor!, range: NSRange(location: 0, length: (s.name as NSString).length))
            speakerList.append(whoAttributedString)
        }
        
        eventNameLabel.contentMode = UIView.ContentMode.top
        
        if event!.speakers.count == 0 {
            speakerList = NSMutableAttributedString(string: "Anonymous")
            eventNameLabel.isHidden = true
        } else {
            let touchSpeaker = UITapGestureRecognizer(target: self, action: #selector(expand))
            eventNameLabel.isUserInteractionEnabled = true
            eventNameLabel.addGestureRecognizer(touchSpeaker)
            eventNameLabel.attributedText = speakerList
            eventNameLabel.layer.borderColor = UIColor.darkGray.cgColor
            eventNameLabel.layer.borderWidth = 0.5
            eventNameLabel.layer.cornerRadius = 5
        }
    }
    
    func setupSpeakers() {
        
        var i = 1
        for s in speakers {
            
            let n = s.name
            let t = s.title
            let d = s.description
                
                let whoAttributedString = NSMutableAttributedString(string:n)
                let whoParagraphStyle = NSMutableParagraphStyle()
                whoParagraphStyle.alignment = .left
                whoAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: whoParagraphStyle, range: NSRange(location: 0, length: (n as NSString).length))
                whoAttributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Bungee", size: 17) ?? UIFont.systemFont(ofSize: 17), range: NSRange(location: 0, length: (n as NSString).length))
                whoAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: eventNameLabel.textColor!, range: NSRange(location: 0, length: (n as NSString).length))
                
                let titleAttributedString = NSMutableAttributedString(string:t)
                let titleParagraphStyle = NSMutableParagraphStyle()
                titleParagraphStyle.alignment = .left
                titleAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: titleParagraphStyle, range: NSRange(location: 0, length: (t as NSString).length))
                titleAttributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Bungee", size: 14) ?? UIFont.systemFont(ofSize: 14), range: NSRange(location: 0, length: (t as NSString).length))
                titleAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: titleParagraphStyle, range: NSRange(location: 0, length: (t as NSString).length))
                
                let bioAttributedString = NSMutableAttributedString(string:d)
                let bioParagraphStyle = NSMutableParagraphStyle()
                bioParagraphStyle.alignment = .left
                bioAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: bioParagraphStyle, range: NSRange(location: 0, length: (d as NSString).length))
                bioAttributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Larsseit", size: 14)!, range: NSRange(location: 0, length: (d as NSString).length))
                bioAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: (d as NSString).length))
                
                
                speakerBios.append(whoAttributedString)
                speakerBios.append(NSAttributedString(string:"\n"))
            if t != "" {
                speakerBios.append(titleAttributedString)
                speakerBios.append(NSAttributedString(string:"\n\n"))
            } else {
                speakerBios.append(NSAttributedString(string:"\n"))
            }
                speakerBios.append(bioAttributedString)
                if speakers.count > 1, i < speakers.count {
                    speakerBios.append(NSAttributedString(string:"\n\n"))
                }
                
                let twitter = s.twitter
                if twitter != "" {
                        let twitButton = UIButton()
                        twitButton.setTitle(twitter, for: .normal)
                        twitButton.setTitleColor(UIColor(hexString: "#98b7e1"), for: .normal)
                        twitButton.addTarget(self, action: #selector(twitterFollow), for: .touchUpInside)
                        twitButton.titleLabel?.font = UIFont(name: "Larsseit", size: 14)
                        twitButton.sizeToFit()
                        twitterStackView.addArrangedSubview(twitButton)
                }
            
            
            i = i+1
        }
        
        //let touchGesture = UILongPressGestureRecognizer(target: self, action: #selector(mapDetailTapped))
        //touchGesture.minimumPressDuration = 0.0
        //touchGesture.cancelsTouchesInView = false
        //locationMapView.addGestureRecognizer(touchGesture)
    }

    @objc func expand() {
        if self.eventNameLabel.attributedText == speakerList {
            if speakerBios.length < 1 {
                setupSpeakers()
            }
            self.eventNameLabel.attributedText = speakerBios
            twitterStackView.isHidden = false // TODO
            
        } else {
            self.eventNameLabel.attributedText = speakerList
            twitterStackView.isHidden = true
        }
        
        UIView.animate(withDuration: 0.3) {
           self.view.layoutIfNeeded()
        }
    }
    
    @objc func twitterFollow(sender: UIButton!) {
        if let twit = sender.titleLabel?.text {
            let l = "https://mobile.twitter.com/\(twit.replacingOccurrences(of: "@", with: ""))"
            if let u = URL(string: l) {
                let svc = SFSafariViewController(url: u)
                svc.preferredBarTintColor = UIColor.backgroundGray
                svc.preferredControlTintColor = UIColor.white
                present(svc, animated: true, completion: nil)
            }
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
        
        /*if (event.starred) {
            event.starred = false
            eventStarredButton.image = #imageLiteral(resourceName: "star_inactive")
            saveContext()
            removeNotification(event)

            reloadEvents()
        } else {
            
            let _duplicates = dataRequest.findConflictingStarredEvents(event)
            
            if let duplicates = _duplicates, duplicates.count > 0
            {
                let duplicateTitles = duplicates.reduce("", { (result, event) -> String in
                    
                    if let t = event.title {
                        if result == ""
                        {
                            return "• \(t)"
                        }
                        else
                        {
                            return result + "\n" + "• \(t)"
                        }
                    } else {
                        return "• Title Not Found"
                    }
                    
                })
                
                var alertBody = "Duplicate event" + (duplicates.count > 1 ? "s" : "") + ":\n" + duplicateTitles +  "\n\nAdd 'Title Not Found' to schedule?"
                if let t = event.title {
                    alertBody = "Duplicate event" + (duplicates.count > 1 ? "s" : "") + ":\n" + duplicateTitles +  "\n\nAdd " + "\'\(t)\'" + " to schedule?"
                }
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = NSTextAlignment.left
                let messageText = NSMutableAttributedString(
                    string: alertBody,
                    attributes: [
                        NSAttributedString.Key.paragraphStyle: paragraphStyle,
                        NSAttributedString.Key.font: UIFont(name: "Larsseit", size: 14)!,
                        NSAttributedString.Key.foregroundColor : UIColor.black
                    ]
                )
                
                let alert : UIAlertController = UIAlertController(title: "Schedule Conflict", message:"", preferredStyle: UIAlertController.Style.alert)
                alert.setValue(messageText, forKey: "attributedMessage")
                
                let yesItem : UIAlertAction = UIAlertAction(title: "Add Anyway", style: UIAlertAction.Style.default, handler: {
                    (action:UIAlertAction) in
                    event.starred = true
                    self.eventStarredButton.image = #imageLiteral(resourceName: "star_active")
                    self.saveContext()
                    scheduleNotification(at: (event.start_date?.addingTimeInterval(-600))!,event)
                    self.reloadEvents()
                })
                
                let noItem : UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler:
                {
                    (action:UIAlertAction) in
                })
                
                alert.addAction(yesItem)
                alert.addAction(noItem)

                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                event.starred = true
                eventStarredButton.image = #imageLiteral(resourceName: "star_active")
                saveContext()
                if let start = event.start_date {
                    scheduleNotification(at: start.addingTimeInterval(-600),event)
                }

                reloadEvents()
            }

        } */

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
    
    @IBAction func followLink(_ sender: Any) {
        if let e = event {
            
            if let u = URL(string: e.links) {
                let svc = SFSafariViewController(url: u)
                svc.preferredBarTintColor = UIColor.backgroundGray
                svc.preferredControlTintColor = UIColor.white
                present(svc, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func shareEvent(_ sender: Any) {
        let dfu = DateFormatterUtility.shared
        if let e = event {
            let time = dfu.dayOfWeekTimeFormatter.string(from: e.beginDate)
            let item = "\(e.conferenceName): Attending '\(e.title)' on \(time) in \(e.location.name) #hackertracker"
            
            let activityViewController : UIActivityViewController = UIActivityViewController(
                activityItems: [item], applicationActivities: nil)
            
            // This lines is for the popover you need to show in iPad
            activityViewController.popoverPresentationController?.sourceView = self.view
            
            // This line remove the arrow of the popover to show in iPad
            activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
            
            // Anything you want to exclude
            activityViewController.excludedActivityTypes = [
                UIActivity.ActivityType.postToWeibo,
                UIActivity.ActivityType.print,
                UIActivity.ActivityType.assignToContact,
                UIActivity.ActivityType.saveToCameraRoll,
                UIActivity.ActivityType.addToReadingList,
                UIActivity.ActivityType.postToFlickr,
                UIActivity.ActivityType.postToVimeo,
                UIActivity.ActivityType.postToTencentWeibo
            ]
            
            self.present(activityViewController, animated: true, completion: nil)
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
    
}
