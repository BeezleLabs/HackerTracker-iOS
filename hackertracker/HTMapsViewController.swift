//
//  HTMapsViewController.swift
//  hackertracker
//
//  Created by Seth Law on 5/11/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit

class HTMapsViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var mapSwitch: UISegmentedControl!
    
    var mapViews : [ReaderContentView] = []
    var mapView : ReaderContentView?

    var roomDimensions : CGRect?
    var timeOfDay : TimeOfDay?

    var mapLocation : Location = .unknown {
        didSet {
            switch mapLocation {
            case .track1:
                roomDimensions = CGRect(x: 1196.0, y: 712.0, width: 539.0, height: 338.0)
                break
            case .unknown:
                break
            default:
                break
            }
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapSwitch.removeAllSegments()
        automaticallyAdjustsScrollViewInsets = false
        var i = 0
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let storageRef = FSConferenceDataController.shared.storage.reference()
        for m in AnonymousSession.shared.currentConference.maps {
            let path = "\(AnonymousSession.shared.currentConference.code)/\(m.file)"
            let mLocal = docDir.appendingPathComponent(path)
            let mRef = storageRef.child(path)
            mapSwitch.insertSegment(withTitle: m.name, at: i, animated: false)
            
            if let rcv = ReaderContentView(frame: self.view.frame, fileURL: mLocal, page: 0, password: "") {
                view.addSubview(rcv)
                mapViews.append(rcv)
                rcv.isHidden = true
                rcv.isUserInteractionEnabled = false
            }
            i = i + 1
        }
        mapSwitch.apportionsSegmentWidthsByContent = true
        mapSwitch.selectedSegmentIndex = 0
        mapChanged(mapSwitch)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyDoneButtonIfNeeded()
    }
    
    func applyDoneButtonIfNeeded() {
        guard let _ = self.navigationController?.parent as? HTHamburgerMenuViewController else {
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
            doneButton.tintColor = .white
            navigationItem.rightBarButtonItem = doneButton
            return
        }
    }

    func zoomToLocation(_ roomDimensions: CGRect) {
        let size = self.view.frame.size

        let widthScale = size.width/roomDimensions.width
        let heightScale = size.height/roomDimensions.height

        let maxZoom : CGFloat = mapView?.maximumZoomScale ?? 4

        let scale : CGFloat

        if widthScale * roomDimensions.height < size.height
        {
            scale = min(maxZoom, widthScale)
        } else {
            scale = min(maxZoom, heightScale)
        }

        mapView?.zoomScale = scale

        let roomCorner = CGPoint(x: roomDimensions.origin.x * scale, y: roomDimensions.origin.y * scale)
        let roomSize = CGSize(width: roomDimensions.size.width * scale, height: roomDimensions.size.height * scale)

        let roomCenter = CGPoint(x: roomCorner.x + (roomSize.width / 2), y: roomCorner.y + (roomSize.height / 2))

        mapView?.contentOffset = CGPoint(x: roomCenter.x - (size.width/2), y: roomCenter.y - (size.height/2))

    }
    
    @objc func doneButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func mapChanged(_ sender: UISegmentedControl) {
        for i in 0...AnonymousSession.shared.currentConference.maps.count-1 {
                mapViews[i].isHidden = true
                mapViews[i].isUserInteractionEnabled = false
        }
        NSLog("switching to segment \(sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "")")
        mapViews[sender.selectedSegmentIndex].isHidden = false
        mapViews[sender.selectedSegmentIndex].isUserInteractionEnabled = true
    }
}
