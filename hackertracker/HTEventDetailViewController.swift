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
    var bookmark: Bookmark?
    var speakers: [HTSpeaker] = []
    var speakerTokens: [UpdateToken] = []
    var myCon: ConferenceModel?
    var eventToken: UpdateToken?

    /*
     //Keep around for map view visual testing
     var eventLocations : [Location] = [.track_101, .track1_101, .track2, .track2_101, .track3, .track4, .capri, .modena, .trevi, .bioHackingVillage, .cryptoAndPrivacyVillage, .hardwareHackingVillage, .icsVillage, .iotVillage, .lockpickVillage, .packetCaptureVillage, .socialEngineerVillage, .tamperEvidentVillage, .wirelessVillage, .unknown]
     */

    override func viewDidLoad() {
        super.viewDidLoad()

        if let _ = eventToken {
            loadEvent()
        } else {
            if let event = event {
                eventToken = FSConferenceDataController.shared.requestEvents(forConference: AnonymousSession.shared.currentConference, eventId: event.id) { (result) in
                    switch result {
                    case .success(let retEvent):
                        self.event = retEvent.event
                        self.bookmark = retEvent.bookmark
                        self.loadEvent()
                    case .failure(_):
                        NSLog("")
                    }
                }
            }
        }

        self.navigationController?.navigationBar.backgroundColor = .black
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.isTranslucent = false

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
        let touchLocation = UITapGestureRecognizer(target: self, action: #selector(gotoMap))
        eventLocationLabel.text = event.location.name
        eventLocationLabel.addGestureRecognizer(touchLocation)
        eventLocationLabel.isUserInteractionEnabled = true

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

        let eventAttributedString = NSMutableAttributedString(string: event.description)
        let eventParagraphStyle = NSMutableParagraphStyle()
        eventParagraphStyle.alignment = .left
        eventAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: eventParagraphStyle, range: NSRange(location: 0, length: (event.description as NSString).length))
        eventAttributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.preferredFont(forTextStyle: .body), range: NSRange(location: 0, length: (event.description as NSString).length))
        eventAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: (event.description as NSString).length))
        eventDetailTextView.attributedText = eventAttributedString

        if let bookmark = bookmark, bookmark.value == true {
            eventStarredButton.image = #imageLiteral(resourceName: "star_active")
        } else {
            eventStarredButton.image = #imageLiteral(resourceName: "star_inactive")
        }

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
        let eventLabel = dfu.shortDayMonthDayTimeOfWeekFormatter.string(from: event.begin)
        let tzLabel = dfu.timezoneFormatter.string(from: event.begin)
        var eventEnd = ""
        if Calendar.current.isDate(event.end, inSameDayAs: event.begin) {
            eventEnd = dfu.hourMinuteTimeFormatter.string(from: event.end)
        } else {
            eventEnd = dfu.dayOfWeekTimeFormatter.string(from: event.end)
        }
        eventDateLabel.text = "\(eventLabel)-\(eventEnd) \(tzLabel)"
        eventDateLabel.font = eventDateLabel.font.withSize(18)

        let addCalendarTap = UITapGestureRecognizer(target: self, action: #selector(addToCalendar))
        eventDateLabel.addGestureRecognizer(addCalendarTap)
        eventDateLabel.isUserInteractionEnabled = true
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

        var i = 0
        for s in event!.speakers {
            if speakerTokens.indices.contains(i) {
                // already have this speaker token
            } else {
                let sToken = FSConferenceDataController.shared.requestSpeaker(forConference: AnonymousSession.shared.currentConference, speakerId: s.id) { (result) in
                    switch result {
                    case .success(let speaker):
                        if self.speakers.contains(speaker) {
                            // NSLog("Speaker \(speaker.name) is already in the list")
                        } else {
                            self.speakers.append(speaker)
                        }
                        self.setupSpeakerNames()
                    case .failure(let error):
                        NSLog("Event detail speaker error: \(error.localizedDescription)")
                    }
                }
                speakerTokens.append(sToken)
            }
            i = i + 1
        }

    }

    func setupSpeakerNames() {
        eventNameLabel.textColor = UIColor(hexString: "#98b7e1")

        eventNameLabel.text = ""
        speakerList = NSMutableAttributedString(string: "")
        for s in event!.speakers {
            if s.id != event!.speakers.first!.id {
                speakerList.append(NSAttributedString(string: ", "))
            }
            let whoAttributedString = NSMutableAttributedString(string: s.name)
            let whoParagraphStyle = NSMutableParagraphStyle()
            whoParagraphStyle.alignment = .left
            whoAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: whoParagraphStyle, range: NSRange(location: 0, length: (s.name as NSString).length))
            whoAttributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.preferredFont(forTextStyle: .title3), range: NSRange(location: 0, length: (s.name as NSString).length))
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

        if (event?.speakers.count)! > 0 {
            eventNameLabel.isHidden = false
        } else {
            eventNameLabel.isHidden = true
        }
    }

    func setupSpeakers() {

        var i = 1
        for s in speakers {

            let n = s.name
            let t = s.title
            let d = s.description

            let whoAttributedString = NSMutableAttributedString(string: n)
            let whoParagraphStyle = NSMutableParagraphStyle()
            whoParagraphStyle.alignment = .left
            whoAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: whoParagraphStyle, range: NSRange(location: 0, length: (n as NSString).length))
            whoAttributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.preferredFont(forTextStyle: .title3), range: NSRange(location: 0, length: (n as NSString).length))
            whoAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: eventNameLabel.textColor!, range: NSRange(location: 0, length: (n as NSString).length))

            let titleAttributedString = NSMutableAttributedString(string: t)
            let titleParagraphStyle = NSMutableParagraphStyle()
            titleParagraphStyle.alignment = .left
            titleAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: titleParagraphStyle, range: NSRange(location: 0, length: (t as NSString).length))
            titleAttributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.preferredFont(forTextStyle: .subheadline), range: NSRange(location: 0, length: (t as NSString).length))
            titleAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: titleParagraphStyle, range: NSRange(location: 0, length: (t as NSString).length))

            let bioAttributedString = NSMutableAttributedString(string: d)
            let bioParagraphStyle = NSMutableParagraphStyle()
            bioParagraphStyle.alignment = .left
            bioAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: bioParagraphStyle, range: NSRange(location: 0, length: (d as NSString).length))
            bioAttributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.preferredFont(forTextStyle: .body), range: NSRange(location: 0, length: (d as NSString).length))
            bioAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: (d as NSString).length))

            speakerBios.append(whoAttributedString)
            speakerBios.append(NSAttributedString(string: "\n"))
            if t != "" {
                speakerBios.append(titleAttributedString)
                speakerBios.append(NSAttributedString(string: "\n\n"))
            } else {
                speakerBios.append(NSAttributedString(string: "\n"))
            }
            speakerBios.append(bioAttributedString)
            if speakers.count > 1, i < speakers.count {
                speakerBios.append(NSAttributedString(string: "\n\n"))
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

        // let touchGesture = UILongPressGestureRecognizer(target: self, action: #selector(mapDetailTapped))
        // touchGesture.minimumPressDuration = 0.0
        // touchGesture.cancelsTouchesInView = false
        // locationMapView.addGestureRecognizer(touchGesture)
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

        addBookmark(bookmark: bookmark, event: event)
    }

    func reloadEvents() {
        if let splitViewController = self.splitViewController,
            !splitViewController.isCollapsed {
            delegate?.reloadEvents()
        }
    }

    func saveContext() {
        let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        var err: NSError?
        do {
            try context.save()
        } catch let error as NSError {
            err = error
        }
        if err != nil {
            NSLog("%@", err!)
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
            let time = dfu.dayOfWeekTimeFormatter.string(from: e.begin)
            let item = "\(e.conferenceName): Attending '\(e.title)' on \(time) in \(e.location.name) #hackertracker"

            let activityViewController: UIActivityViewController = UIActivityViewController(
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

    @objc func gotoMap() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let mapView = storyboard.instantiateViewController(withIdentifier: "HTMapsViewController") as! HTMapsViewController
        mapView.hotel = event?.location.hotel
        let navigationController = HTEventsNavViewController(rootViewController: mapView)
        self.present(navigationController, animated: true, completion: nil)
    }

    @objc func mapDetailTapped(tapGesture: UILongPressGestureRecognizer) {
        let touchPoint = tapGesture.location(in: tapGesture.view)

        let touchRect = CGRect(origin: touchPoint, size: CGSize(width: 1, height: 1))

        let intersecting = touchRect.intersects(locationMapView.bounds)

        locationMapView.alpha = intersecting ? 0.5 : 1.0

        switch tapGesture.state {
        case .ended:
            if intersecting {
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let mapView = storyboard.instantiateViewController(withIdentifier: "HTMapsViewController") as! HTMapsViewController
                // mapView.mapLocation = locationMapView.currentLocation
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

    @objc func addToCalendar() {
        guard let htEvent = event else { return }
        let calendarUtility = CalendarUtility()
        calendarUtility.addEvent(htEvent: htEvent, view: self)
    }

}
