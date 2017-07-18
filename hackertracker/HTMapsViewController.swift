//
//  HTMapsViewController.swift
//  hackertracker
//
//  Created by Seth Law on 5/11/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit

class HTMapsViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var dayView: UIWebView!
    @IBOutlet weak var nightView: UIWebView!
    @IBOutlet weak var dayTimeSwitch: UISegmentedControl!
    
    var dayMapView : ReaderContentView?
    var nightMapView : ReaderContentView?

    var roomDimensions : CGRect?
    var timeOfDay : TimeOfDay?

    var mapLocation : Location = .unknown {
        didSet {
            switch mapLocation {
            case .track_101, .track1_101:
                roomDimensions = CGRect(x: 853, y: 767, width: 116, height: 222)
                break
            case .track2, .track2_101:
                roomDimensions = CGRect(x: 787, y: 255, width: 135, height: 235)
                break
            case .track3:
                roomDimensions = CGRect(x: 212, y: 332, width: 112, height: 187)
                break
            case .track4:
                roomDimensions = CGRect(x: 315, y: 332, width: 90, height: 187)
                break
            case .capri:
                roomDimensions = CGRect(x: 483, y: 947, width: 38, height: 49)
                break
            case .modena:
                roomDimensions = CGRect(x: 530, y: 688, width: 38, height: 36)
                break
            case .trevi:
                roomDimensions = CGRect(x: 532, y: 604, width: 44, height: 35)
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
    
    func configure(contentOffset : CGPoint, zoom : CGFloat, timeOfDay : TimeOfDay)
    {
        dayTimeSwitch.selectedSegmentIndex = timeOfDay == .day  ? 0 : 1
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false
        
        let dayFile = Bundle.main.url(forResource: "dc-25-floorplan-v7.5-public", withExtension: "pdf")
        let nightFile = Bundle.main.url(forResource: "dc-25-floorplan-night", withExtension: "pdf")

        dayMapView = ReaderContentView(frame: self.view.frame, fileURL: dayFile!, page: 0, password: "")
        view.addSubview(dayMapView!)

        dayMapView?.backgroundColor = UIColor.backgroundGray

        nightMapView = ReaderContentView(frame: self.view.frame, fileURL: nightFile!, page: 0, password: "")
        view.addSubview(nightMapView!)

        nightMapView?.backgroundColor = UIColor.backgroundGray

        dayMapView?.maximumZoomScale = 8
        nightMapView?.maximumZoomScale = 8

        mapTypeChanged(dayTimeSwitch)
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

        if let timeOfDay = timeOfDay {
            dayTimeSwitch.selectedSegmentIndex = timeOfDay == .night ? 1 : 0
        } else {
            dayTimeSwitch.selectedSegmentIndex = TimeOfDay.timeOfDay(for: Date()) == .night ? 1 : 0
        }

        mapTypeChanged(dayTimeSwitch)
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
        nightMapView?.contentOffset = CGPoint(x: roomCenter.x - (size.width/2), y: roomCenter.y - (size.height/2))

    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let setterView = scrollView == dayMapView ? nightMapView : dayMapView
        let getterView = scrollView

        setterView?.zoomScale = getterView.zoomScale
        setterView?.contentOffset = getterView.contentOffset
    }
    
    @IBAction func mapTypeChanged(_ sender: UISegmentedControl) {
        let isDay = sender.selectedSegmentIndex == 0
        let isNight = !isDay

        dayMapView?.isHidden = isNight
        nightMapView?.isHidden = isDay

        dayMapView?.isUserInteractionEnabled = isDay
        nightMapView?.isUserInteractionEnabled = isNight

        nightMapView?.mapScrollViewDelegate = isNight ? self : nil
        dayMapView?.mapScrollViewDelegate = isDay ? self : nil
    }
    
    func doneButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
}
