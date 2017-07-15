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

    private var zoomScale : CGFloat?
    private var contentOffset : CGPoint?

    var mapLocation : Location = .unknown {
        didSet {
            switch mapLocation {
            case .track_101, .track1_101:
                zoomScale = 3.02224430930721
                contentOffset = CGPoint(x:2549.66666666667, y:2324.33333333333)
            case .track2, .track2_101:
                zoomScale = 2.71027146283724
                contentOffset = CGPoint(x:2120.33333333333, y:664.333333333333)
            case .track3:
                zoomScale = 3.25491527203501
                contentOffset = CGPoint(x:681.666666666667, y:1070.66666666667)
                break
            case .track4:
                zoomScale = 3.25491527203501
                contentOffset = CGPoint(x:984.0, y:1058.66666666667)
                break
            case .capri:
                zoomScale = 5.54773869346734
                contentOffset = CGPoint(x:2592.66666666667, y:5041.66666666667)
                break
            case .modena:
                zoomScale = 5.54773869346734
                contentOffset = CGPoint(x:2840.66666666667, y:3623.0)
                break
            case .trevi:
                zoomScale = 5.54773869346734
                contentOffset = CGPoint(x:2871.66666666667, y:3158.0)
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
        
        dayMapView?.mapScrollViewDelegate = self
        dayMapView?.backgroundColor = UIColor.backgroundGray

        nightMapView = ReaderContentView(frame: self.view.frame, fileURL: nightFile!, page: 0, password: "")
        view.addSubview(nightMapView!)
        
        nightMapView?.mapScrollViewDelegate = self
        nightMapView?.backgroundColor = UIColor.backgroundGray
        nightMapView?.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.tabBarController == nil
        {
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
            doneButton.tintColor = .white
            navigationItem.rightBarButtonItem = doneButton
        }
        
        if let zoomScale = zoomScale, let contentOffset = contentOffset {
            dayMapView?.zoomScale = zoomScale
            dayMapView?.contentOffset = contentOffset
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      
        let setterView = scrollView == dayMapView ? nightMapView : dayMapView
        let getterView = scrollView
        
        setterView?.zoomScale = getterView.zoomScale
        setterView?.contentOffset = getterView.contentOffset
    }
    
    @IBAction func mapTypeChanged(_ sender: UISegmentedControl) {
        dayMapView?.isHidden = sender.selectedSegmentIndex != 0
        nightMapView?.isHidden = sender.selectedSegmentIndex != 1
    }
    
    func doneButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
}
