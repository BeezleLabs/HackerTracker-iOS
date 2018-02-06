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
                roomDimensions = CGRect(x: 107.47, y: 197.77, width: 98.09, height: 90.5)
                break
            case .track2:
                roomDimensions = CGRect(x: 295.01, y: 188.37, width: 86.2, height: 73.48)
                break
            case .seminars:
                roomDimensions = CGRect(x: 138.88, y: 348.61, width: 70.95, height: 73.48)
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
