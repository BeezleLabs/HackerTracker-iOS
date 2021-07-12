//
//  HTMapsViewController.swift
//  hackertracker
//
//  Created by Seth Law on 5/11/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import PDFKit
import UIKit

class HTMapsViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet private var mapSwitch: UISegmentedControl!

    var mapViews: [PDFView] = []
    var mapView: PDFView?

    var roomDimensions: CGRect?
    var timeOfDay: TimeOfDay?

    var hotel: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        mapSwitch.removeAllSegments()
        var idx = 0
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileManager = FileManager.default
        // let storageRef = FSConferenceDataController.shared.storage.reference()
        for map in AnonymousSession.shared.currentConference.maps {
            let path = "\(AnonymousSession.shared.currentConference.code)/\(map.file)"
            let mLocal = docDir.appendingPathComponent(path)
            // let mRef = storageRef.child(path)
            mapSwitch.insertSegment(withTitle: map.name, at: idx, animated: false)

            defer { idx += 1 }
            guard fileManager.fileExists(atPath: mLocal.path) else {
                NSLog("Don't have a local copy of the file at \(mLocal.path)")
                continue
            }
            let pdfView = PDFView()
            pdfView.backgroundColor = UIColor.black
            pdfView.autoScales = true
            pdfView.translatesAutoresizingMaskIntoConstraints = false

            pdfView.document = PDFDocument(url: mLocal)
            view.addSubview(pdfView)

            pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

            mapViews.append(pdfView)
            pdfView.isHidden = true
            pdfView.isUserInteractionEnabled = false

            NSLog("Adding PDFView for \(mLocal.path)")
        }
        mapSwitch.apportionsSegmentWidthsByContent = true
        mapSwitch.sizeToFit()

        goToHotel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if hotel != nil {
            goToHotel()
        }
        applyDoneButtonIfNeeded()
    }

    func goToHotel() {
        var selectedIndex = 0
        if let hotel = hotel {
            for index in 0..<mapSwitch.numberOfSegments {
                if let title = mapSwitch.titleForSegment(at: index) {
                    if title.contains(hotel) {
                        selectedIndex = index
                    }
                }
            }
        }
        mapSwitch.selectedSegmentIndex = selectedIndex
        mapChanged(mapSwitch)
    }

    func applyDoneButtonIfNeeded() {
        guard self.navigationController?.parent as? HTHamburgerMenuViewController != nil else {
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
            doneButton.tintColor = .white
            navigationItem.rightBarButtonItem = doneButton
            return
        }
    }

    @objc func doneButtonPressed() {
        self.dismiss(animated: true)
    }

    @IBAction private func mapChanged(_ sender: UISegmentedControl) {
        guard !mapViews.isEmpty else { return }

        for index in 0..<AnonymousSession.shared.currentConference.maps.count {
                mapViews[index].isHidden = true
                mapViews[index].isUserInteractionEnabled = false
        }
        NSLog("switching to segment \(sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "")")
        mapViews[sender.selectedSegmentIndex].isHidden = false
        mapViews[sender.selectedSegmentIndex].isUserInteractionEnabled = true
    }
}
