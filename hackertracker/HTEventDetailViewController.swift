//
//  HTEventDetailViewController.swift
//  hackertracker
//
//  Created by Seth Law on 4/17/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import CoreData
import SafariServices
import UIKit
import UserNotifications

protocol EventDetailDelegate: AnyObject {
    func reloadEvents()
}

class HTEventDetailViewController: UIViewController { // swiftlint:disable:this type_body_length
    @IBOutlet private var eventTitleLabel: UILabel!
    @IBOutlet private var eventNameLabel: UILabel!
    @IBOutlet private var eventDateLabel: UILabel!
    @IBOutlet private var eventLocationLabel: UILabel!
    @IBOutlet private var eventDetailTextView: UITextView!
    @IBOutlet private var eventStarredButton: UIBarButtonItem!
    @IBOutlet private var demoImage: UIImageView!
    @IBOutlet private var exploitImage: UIImageView!
    @IBOutlet private var toolImage: UIImageView!
    @IBOutlet private var locationMapView: MapLocationView!
    @IBOutlet private var eventTypeContainer: UIStackView!
    @IBOutlet private var bottomPaddingConstraint: NSLayoutConstraint!
    @IBOutlet private var eventTypeLabel: UILabel!
    @IBOutlet private var linkButton: UIButton!
    @IBOutlet private var twitterStackView: UIStackView!

    var speakerBios = NSMutableAttributedString(string: "")
    var speakerList = NSMutableAttributedString(string: "")

    weak var delegate: EventDetailDelegate?
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

        if eventToken != nil {
            loadEvent()
        } else {
            if let event = event {
                eventToken = FSConferenceDataController.shared.requestEvents(forConference: AnonymousSession.shared.currentConference, eventId: event.id) { result in
                    switch result {
                    case let .success(retEvent):
                        self.event = retEvent.event
                        self.bookmark = retEvent.bookmark
                        self.loadEvent()
                    case .failure:
                        // TODO: Properly log failure
                        break
                    }
                }
            }
        }

        navigationController?.navigationBar.backgroundColor = .black
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = false
    }

    func loadEvent() { // swiftlint:disable:this function_body_length
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

        /* if let l = event.location, let n = l.name {
         locationMapView.currentLocation = Location.valueFromString(n)
         } else {
         locationMapView.currentLocation = .unknown
         }
         locationMapView.setup() */

        let eventAttributedString = NSMutableAttributedString(string: event.description, attributes: [
            .paragraphStyle: NSParagraphStyle.leftAlignedParagraph,
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.white,
        ])
        // eventDetailTextView.attributedText = eventAttributedString

        if let bookmark = bookmark, bookmark.value == true {
            eventStarredButton.image = UIImage(systemName: "star.fill")
        } else {
            eventStarredButton.image = UIImage(systemName: "star")
        }

        let includes = event.includes
        if !includes.lowercased().contains("tool") { toolImage.isHidden = true }
        if !includes.lowercased().contains("demo") { demoImage.isHidden = true }
        if !includes.lowercased().contains("exploit") { exploitImage.isHidden = true }
        if !includes.isEmpty {
            let includesHeader = NSMutableAttributedString(string: "Includes", attributes: [
                .paragraphStyle: NSParagraphStyle.leftAlignedParagraph,
                .font: UIFont.preferredFont(forTextStyle: .title3),
                .foregroundColor: UIColor.orange,
            ])
            eventAttributedString.append(includesHeader)
            let includesText = NSMutableAttributedString(string: "\n - \(includes.uppercased())", attributes: [
                .paragraphStyle: NSParagraphStyle.leftAlignedParagraph,
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: UIColor.white,
            ])
            eventAttributedString.append(includesText)
        }

        if event.links.isEmpty {
            linkButton.isHidden = true
            linkButton.isEnabled = false
        } else {
            if event.links.contains(where: { $0.url.contains("https://forum.defcon.org") }) {
                linkButton.isHidden = false
                linkButton.isEnabled = true
            }
            let linksText = NSMutableAttributedString(string: "\nLinks", attributes: [
                .paragraphStyle: NSParagraphStyle.leftAlignedParagraph,
                .font: UIFont.preferredFont(forTextStyle: .title3),
                .foregroundColor: UIColor(hex: "#326295") ?? UIColor.deepPurple,
            ])
            event.links.forEach { link in
                let linkText = NSMutableAttributedString(string: "\n - \(link.label): \(link.url)", attributes: [
                    .paragraphStyle: NSParagraphStyle.leftAlignedParagraph,
                    .font: UIFont.preferredFont(forTextStyle: .body),
                    .foregroundColor: UIColor.white,
                ])
                linksText.append(linkText)
            }

            eventAttributedString.append(linksText)
        }
        eventDetailTextView.attributedText = eventAttributedString

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
        let eventDateAttributedText = NSMutableAttributedString(string: "\(eventLabel)-\(eventEnd) \(tzLabel) ")
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: "calendar.badge.plus")
        attachment.image = attachment.image?.withTintColor(UIColor.white)
        let attachmentStr = NSAttributedString(attachment: attachment)
        eventDateAttributedText.append(attachmentStr)
        eventDateLabel.attributedText = eventDateAttributedText
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
        guard navigationController?.parent as? HTHamburgerMenuViewController != nil else {
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
            doneButton.tintColor = .white
            navigationItem.rightBarButtonItem = doneButton
            return
        }
    }

    @objc func doneButtonPressed() {
        dismiss(animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        eventDetailTextView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }

    func getSpeakers() {
        var idx = 0
        for speaker in event?.speakers ?? [] {
            if speakerTokens.indices.contains(idx) {
                // already have this speaker token
            } else {
                let sToken = FSConferenceDataController.shared.requestSpeaker(forConference: AnonymousSession.shared.currentConference, speakerId: speaker.id) { result in
                    switch result {
                    case let .success(speaker):
                        if self.speakers.contains(speaker) {
                            // NSLog("Speaker \(speaker.name) is already in the list")
                        } else {
                            self.speakers.append(speaker)
                        }
                        self.setupSpeakerNames()
                    case let .failure(error):
                        NSLog("Event detail speaker error: \(error.localizedDescription)")
                    }
                }
                speakerTokens.append(sToken)
            }
            idx += 1
        }
    }

    func setupSpeakerNames() {
        eventNameLabel.textColor = UIColor(hexString: "#98b7e1")

        eventNameLabel.text = ""
        speakerList = NSMutableAttributedString(string: "")

        // If we can bump up to iOS 13 we can use ListFormatter
        for speaker in event?.speakers ?? [] {
            if speaker.id != event?.speakers.first?.id {
                speakerList.append(NSAttributedString(string: ", "))
            }

            let whoAttributedString = NSMutableAttributedString(string: speaker.name, attributes: [
                .paragraphStyle: NSParagraphStyle.leftAlignedParagraph,
                .font: UIFont.preferredFont(forTextStyle: .title3),
                .foregroundColor: eventNameLabel.textColor!,
            ])

            speakerList.append(whoAttributedString)
        }

        eventNameLabel.contentMode = UIView.ContentMode.top

        if let event = event, event.speakers.isEmpty {
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
            eventNameLabel.isHidden = false
        }
    }

    func setupSpeakers() {
        let eventTextColor = eventNameLabel.textColor!

        var idx = 1

        for speaker in speakers {
            let whoAttributedString = NSMutableAttributedString(string: speaker.name, attributes: [
                .paragraphStyle: NSParagraphStyle.leftAlignedParagraph,
                .font: UIFont.preferredFont(forTextStyle: .title3),
                .foregroundColor: eventTextColor,
            ])

            let titleAttributedString = NSMutableAttributedString(string: speaker.title, attributes: [
                .paragraphStyle: NSParagraphStyle.leftAlignedParagraph,
                .font: UIFont.preferredFont(forTextStyle: .subheadline),
                .foregroundColor: eventTextColor,
            ])

            let bioAttributedString = NSMutableAttributedString(string: speaker.description, attributes: [
                .paragraphStyle: NSParagraphStyle.leftAlignedParagraph,
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: eventTextColor,
            ])

            speakerBios.append(whoAttributedString)
            speakerBios.append(NSAttributedString(string: "\n"))
            if speaker.title.isEmpty {
                speakerBios.append(NSAttributedString(string: "\n"))
            } else {
                speakerBios.append(titleAttributedString)
                speakerBios.append(NSAttributedString(string: "\n\n"))
            }
            speakerBios.append(bioAttributedString)
            if speakers.count > 1, idx < speakers.count {
                speakerBios.append(NSAttributedString(string: "\n\n"))
            }

            let twitter = speaker.twitter
            if !twitter.isEmpty {
                let twitButton = UIButton()
                twitButton.setTitle(twitter, for: .normal)
                twitButton.setTitleColor(UIColor(hexString: "#98b7e1"), for: .normal)
                twitButton.addTarget(self, action: #selector(twitterFollow), for: .touchUpInside)
                twitButton.titleLabel?.font = UIFont(name: "Futura", size: 14)
                twitButton.sizeToFit()
                twitterStackView.addArrangedSubview(twitButton)
            }

            idx += 1
        }

        // let touchGesture = UILongPressGestureRecognizer(target: self, action: #selector(mapDetailTapped))
        // touchGesture.minimumPressDuration = 0.0
        // touchGesture.cancelsTouchesInView = false
        // locationMapView.addGestureRecognizer(touchGesture)
    }

    @objc func expand() {
        if eventNameLabel.attributedText == speakerList {
            if speakerBios.length < 1 {
                setupSpeakers()
            }
            eventNameLabel.attributedText = speakerBios
            twitterStackView.isHidden = false
        } else {
            eventNameLabel.attributedText = speakerList
            twitterStackView.isHidden = true
        }

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func twitterFollow(_ sender: UIButton) {
        if let twit = sender.titleLabel?.text {
            if let url = URL(string: "https://mobile.twitter.com/\(twit.replacingOccurrences(of: "@", with: ""))") {
                let controller = SFSafariViewController(url: url)
                controller.preferredBarTintColor = .backgroundGray
                controller.preferredControlTintColor = .white
                present(controller, animated: true)
            }
        }
    }

    @IBAction private func toggleMySchedule(_ sender: AnyObject) {
        guard let event = event else {
            print("HTEventDetailViewController: Event is nil")
            return
        }

        addBookmark(bookmark: bookmark, event: event)
        self.delegate?.reloadEvents()
    }

    func reloadEvents() {
        if let splitViewController = self.splitViewController,
           !splitViewController.isCollapsed {
            delegate?.reloadEvents()
        }
    }

    func saveContext() {
        do {
            try getContext().save()
        } catch let error as NSError {
            NSLog("%@", error)
        }
    }

    @IBAction private func followLink(_: Any) {
        if let event = event, let forumLink: HTLink = event.links.first(where: { $0.url.contains("https://forum.defcon.org") }) {
            // let forumLink: HTLink = event.links.first(where: { "https://forum.defcon.org" in $0.url })
            guard let url = URL(string: forumLink.url) else {
                return
            }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }

    @IBAction private func shareEvent(_: Any) {
        let dfu = DateFormatterUtility.shared
        if let event = event {
            let time = dfu.dayOfWeekTimeFormatter.string(from: event.begin)
            let item = "\(event.conferenceName): Attending '\(event.title)' on \(time) in \(event.location.name) #hackertracker"

            let activityViewController = UIActivityViewController(
                activityItems: [item], applicationActivities: nil
            )

            // This lines is for the popover you need to show in iPad
            activityViewController.popoverPresentationController?.sourceView = view

            // This line remove the arrow of the popover to show in iPad
            activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)

            // Anything you want to exclude
            activityViewController.excludedActivityTypes = [
                .postToWeibo,
                .print,
                .assignToContact,
                .saveToCameraRoll,
                .addToReadingList,
                .postToFlickr,
                .postToVimeo,
                .postToTencentWeibo,
            ]

            present(activityViewController, animated: true)
        }
    }

    @objc func gotoMap() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let mapView = storyboard.instantiateViewController(withIdentifier: "HTMapsViewController") as! HTMapsViewController
        mapView.hotel = event?.location.hotel
        let navigationController = HTEventsNavViewController(rootViewController: mapView)
        present(navigationController, animated: true)
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
                present(navigationController, animated: true)
            }
            locationMapView.alpha = 1.0
        case .cancelled, .failed:
            locationMapView.alpha = 1.0
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

// swiftlint:disable:this file_length
