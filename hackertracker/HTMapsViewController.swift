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
    
    var caesarsMapView : ReaderContentView?
    var flamingoMapView : ReaderContentView?
    var nightMapView : ReaderContentView?
    var linqMapView : ReaderContentView?

    var roomDimensions : CGRect?
    var timeOfDay : TimeOfDay?

    var mapLocation : Location = .unknown {
        didSet {
            switch mapLocation {
            case .track1:
                roomDimensions = CGRect(x: 1196.0, y: 712.0, width: 539.0, height: 338.0)
                break
            /*case .track2:
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
                break*/
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

        automaticallyAdjustsScrollViewInsets = false
        
        let caesarsFile = Bundle.main.url(forResource: "dc-26-caesars-public-1", withExtension: "pdf", subdirectory: "maps")
        caesarsMapView = ReaderContentView(frame: self.view.frame, fileURL: caesarsFile!, page: 0, password: "")
        view.addSubview(caesarsMapView!)
        caesarsMapView?.backgroundColor = UIColor.backgroundGray
        caesarsMapView?.maximumZoomScale = 8
        
        let flamingoFile = Bundle.main.url(forResource: "dc-26-flamingo-public-1", withExtension: "pdf", subdirectory: "maps")
        flamingoMapView = ReaderContentView(frame: self.view.frame, fileURL: flamingoFile!, page: 0, password: "")
        view.addSubview(flamingoMapView!)
        flamingoMapView?.backgroundColor = UIColor.backgroundGray
        flamingoMapView?.maximumZoomScale = 8
        
        let nightFile = Bundle.main.url(forResource: "dc-26-flamingo-noct-public", withExtension: "pdf", subdirectory: "maps")
        nightMapView = ReaderContentView(frame: self.view.frame, fileURL: nightFile!, page: 0, password: "")
        view.addSubview(nightMapView!)
        nightMapView?.backgroundColor = UIColor.backgroundGray
        nightMapView?.maximumZoomScale = 8
        
        let linqFile = Bundle.main.url(forResource: "dc-26-linq-workshops", withExtension: "pdf", subdirectory: "maps")
        linqMapView = ReaderContentView(frame: self.view.frame, fileURL: linqFile!, page: 0, password: "")
        view.addSubview(linqMapView!)
        linqMapView?.backgroundColor = UIColor.backgroundGray
        linqMapView?.maximumZoomScale = 8
        
        mapChanged(mapSwitch)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyDoneButtonIfNeeded()
        /*if let roomDimensions = roomDimensions, roomDimensions.width > 0, roomDimensions.height > 0 {
            zoomToLocation(roomDimensions)
        }*/
        
        if mapLocation == .unknown {
            mapChanged(mapSwitch)
        } else {
            let l = mapLocation
            if l == .track101 || l == .blueteam || l == .cannabis || l == .chv || l == .caadv || l == .skytalks || l == .ics
            {
                caesarsMapView?.isHidden = true
                flamingoMapView?.isHidden = false
                nightMapView?.isHidden = true
                linqMapView?.isHidden = true
                caesarsMapView?.isUserInteractionEnabled = false
                flamingoMapView?.isUserInteractionEnabled = true
                nightMapView?.isUserInteractionEnabled = false
                linqMapView?.isUserInteractionEnabled = false
                mapSwitch.selectedSegmentIndex = 1
            } else if l == .icona || l == .iconb || l == .iconc || l == .icond || l == .icone || l == .iconf {
                caesarsMapView?.isHidden = true
                flamingoMapView?.isHidden = true
                nightMapView?.isHidden = true
                linqMapView?.isHidden = false
                caesarsMapView?.isUserInteractionEnabled = false
                flamingoMapView?.isUserInteractionEnabled = false
                nightMapView?.isUserInteractionEnabled = false
                linqMapView?.isUserInteractionEnabled = true
                mapSwitch.selectedSegmentIndex = 3
            } else {
                caesarsMapView?.isHidden = false
                flamingoMapView?.isHidden = true
                nightMapView?.isHidden = true
                linqMapView?.isHidden = true
                caesarsMapView?.isUserInteractionEnabled = true
                flamingoMapView?.isUserInteractionEnabled = false
                nightMapView?.isUserInteractionEnabled = false
                linqMapView?.isUserInteractionEnabled = false
            }
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

    func zoomToLocation(_ roomDimensions: CGRect) {
        let size = self.view.frame.size

        let widthScale = size.width/roomDimensions.width
        let heightScale = size.height/roomDimensions.height

        let maxZoom : CGFloat = caesarsMapView?.maximumZoomScale ?? 4

        let scale : CGFloat

        if widthScale * roomDimensions.height < size.height
        {
            scale = min(maxZoom, widthScale)
        } else {
            scale = min(maxZoom, heightScale)
        }

        caesarsMapView?.zoomScale = scale

        let roomCorner = CGPoint(x: roomDimensions.origin.x * scale, y: roomDimensions.origin.y * scale)
        let roomSize = CGSize(width: roomDimensions.size.width * scale, height: roomDimensions.size.height * scale)

        let roomCenter = CGPoint(x: roomCorner.x + (roomSize.width / 2), y: roomCorner.y + (roomSize.height / 2))

        caesarsMapView?.contentOffset = CGPoint(x: roomCenter.x - (size.width/2), y: roomCenter.y - (size.height/2))

    }
    
    @objc func doneButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func mapChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 3:
            caesarsMapView?.isHidden = true
            flamingoMapView?.isHidden = true
            nightMapView?.isHidden = true
            linqMapView?.isHidden = false
            caesarsMapView?.isUserInteractionEnabled = false
            flamingoMapView?.isUserInteractionEnabled = false
            nightMapView?.isUserInteractionEnabled = false
            linqMapView?.isUserInteractionEnabled = true
            break
        case 2:
            caesarsMapView?.isHidden = true
            flamingoMapView?.isHidden = true
            nightMapView?.isHidden = false
            linqMapView?.isHidden = true
            caesarsMapView?.isUserInteractionEnabled = false
            flamingoMapView?.isUserInteractionEnabled = false
            nightMapView?.isUserInteractionEnabled = true
            linqMapView?.isUserInteractionEnabled = false
            break
        case 1:
            caesarsMapView?.isHidden = true
            flamingoMapView?.isHidden = false
            nightMapView?.isHidden = true
            linqMapView?.isHidden = true
            caesarsMapView?.isUserInteractionEnabled = false
            flamingoMapView?.isUserInteractionEnabled = true
            nightMapView?.isUserInteractionEnabled = false
            linqMapView?.isUserInteractionEnabled = false
            break
        default:
            caesarsMapView?.isHidden = false
            flamingoMapView?.isHidden = true
            nightMapView?.isHidden = true
            linqMapView?.isHidden = true
            caesarsMapView?.isUserInteractionEnabled = true
            flamingoMapView?.isUserInteractionEnabled = false
            nightMapView?.isUserInteractionEnabled = false
            linqMapView?.isUserInteractionEnabled = false
            break
            
        }
    }
    
}
