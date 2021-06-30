//
//  HTMapsViewController.swift
//  hackertracker
//
//  Created by Seth Law on 5/11/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import PDFKit

class HTMapsViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var mapSwitch: UISegmentedControl!

    var mapViews: [PDFView] = []
    var mapView: PDFView?

    var roomDimensions: CGRect?
    var timeOfDay: TimeOfDay?

    var hotel: String?

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mapSwitch.removeAllSegments()
        var i = 0
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fm = FileManager.default
        // let storageRef = FSConferenceDataController.shared.storage.reference()
        for m in AnonymousSession.shared.currentConference.maps {
            let path = "\(AnonymousSession.shared.currentConference.code)/\(m.file)"
            let mLocal = docDir.appendingPathComponent(path)
            // let mRef = storageRef.child(path)
            mapSwitch.insertSegment(withTitle: m.name, at: i, animated: false)

            if fm.fileExists(atPath: mLocal.path) {
                let pv = PDFView()
                pv.backgroundColor = UIColor.black
                pv.autoScales = true
                pv.translatesAutoresizingMaskIntoConstraints = false

                pv.document = PDFDocument(url: mLocal)
                self.view.addSubview(pv)

                pv.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
                pv.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
                pv.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
                pv.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

                mapViews.append(pv)
                pv.isHidden = true
                pv.isUserInteractionEnabled = false

                NSLog("Adding PDFView for \(mLocal.path)")
            } else {
                NSLog("Don't have a local copy of the file at \(mLocal.path)")
            }
            i += 1
        }
        mapSwitch.apportionsSegmentWidthsByContent = true
        mapSwitch.sizeToFit()

        goToHotel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = hotel {
            goToHotel()
        }
        applyDoneButtonIfNeeded()
    }

    func goToHotel() {

        var selectedIndex = 0
        if let h = hotel {
            for i in 0..<mapSwitch.numberOfSegments {
                if let m = mapSwitch.titleForSegment(at: i) {
                    if m.contains(h) {
                        selectedIndex = i
                    }
                }
            }
        }
        mapSwitch.selectedSegmentIndex = selectedIndex
        mapChanged(mapSwitch)
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

    @IBAction func mapChanged(_ sender: UISegmentedControl) {
        if mapViews.count <= 0 { return }

        for i in 0..<AnonymousSession.shared.currentConference.maps.count {
                mapViews[i].isHidden = true
                mapViews[i].isUserInteractionEnabled = false
        }
        NSLog("switching to segment \(sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "")")
        mapViews[sender.selectedSegmentIndex].isHidden = false
        mapViews[sender.selectedSegmentIndex].isUserInteractionEnabled = true
    }
}
