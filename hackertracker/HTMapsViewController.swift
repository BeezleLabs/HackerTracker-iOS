//
//  HTMapsViewController.swift
//  hackertracker
//
//  Created by Seth Law on 5/11/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit

class HTMapsViewController: UIViewController, UIScrollViewDelegate {

    
    var dayMapView : ReaderContentView?

    var roomDimensions : CGRect?
    var timeOfDay : TimeOfDay?

    var mapLocation : Location = .unknown {
        didSet {
            switch mapLocation {
            case .track1:
                roomDimensions = CGRect(x: 1196.0, y: 712.0, width: 539.0, height: 338.0)
                break
            case .track2:
                roomDimensions = CGRect(x: 1200.0, y: 276.0, width: 266.0, height: 339.0)
                break
            case .training1:
                roomDimensions = CGRect(x: 50.0, y: 287.0, width: 252.40, height: 233.17)
                break
            case .training2:
                roomDimensions = CGRect(x: 50.0, y: 730.0, width: 252.40, height: 233.17)
                break
            case .training3:
                roomDimensions = CGRect(x: 305.0, y: 715.0, width: 268.00, height: 329.00)
                break
            case .workshop1:
                roomDimensions = CGRect(x: 555.0, y: 712.0, width: 268.00, height: 334.00)
                break
            case .workshop2:
                roomDimensions = CGRect(x: 307.0, y: 287.0, width: 261.00, height: 322.00)
                break
            case .chillout:
                roomDimensions = CGRect(x: 943.0, y: 282.0, width: 277.0, height: 251.0)
                break
            case .lightning:
                roomDimensions = CGRect(x: 950.0, y: 792.0, width: 270.0, height: 258.0)
                break
            case .villages:
                roomDimensions = CGRect(x: 1456.0, y: 276.0, width: 264.0, height: 337.0)
                break
            case .unknown:
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

        automaticallyAdjustsScrollViewInsets = false
        
        let dayFile = Bundle.main.url(forResource: "hackwest-2018-map", withExtension: "pdf")

        dayMapView = ReaderContentView(frame: self.view.frame, fileURL: dayFile!, page: 0, password: "")
        view.addSubview(dayMapView!)

        dayMapView?.backgroundColor = UIColor.backgroundGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.tabBarController == nil
        {
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
            doneButton.tintColor = .white
            navigationItem.rightBarButtonItem = doneButton
        }

        if let roomDimensions = roomDimensions, roomDimensions.width > 0, roomDimensions.height > 0 {
            zoomToLocation(roomDimensions)
        }
    }

    func zoomToLocation(_ roomDimensions: CGRect) {
        let size = self.view.frame.size

        let widthScale = size.width/roomDimensions.width
        let heightScale = size.height/roomDimensions.height

        let maxZoom : CGFloat = dayMapView?.maximumZoomScale ?? 4

        let scale : CGFloat

        if widthScale * roomDimensions.height < size.height
        {
            scale = min(maxZoom, widthScale)
        } else {
            scale = min(maxZoom, heightScale)
        }

        dayMapView?.zoomScale = scale

        let roomCorner = CGPoint(x: roomDimensions.origin.x * scale, y: roomDimensions.origin.y * scale)
        let roomSize = CGSize(width: roomDimensions.size.width * scale, height: roomDimensions.size.height * scale)

        let roomCenter = CGPoint(x: roomCorner.x + (roomSize.width / 2), y: roomCorner.y + (roomSize.height / 2))

        dayMapView?.contentOffset = CGPoint(x: roomCenter.x - (size.width/2), y: roomCenter.y - (size.height/2))

    }
    
    @objc func doneButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
}
