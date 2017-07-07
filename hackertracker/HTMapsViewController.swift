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
    
    @IBAction func mapTypeChanged(_ sender: UISegmentedControl) {
        dayView.isHidden = sender.selectedSegmentIndex != 0
        nightView.isHidden = sender.selectedSegmentIndex != 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let dayFile = Bundle.main.url(forResource: "dc-25-floorplan-v7.5-public", withExtension: "pdf")
        let nightFile = Bundle.main.url(forResource: "dc-25-floorplan-night", withExtension: "pdf")
        
        dayView.loadRequest(URLRequest(url: dayFile!))
        nightView.loadRequest(URLRequest(url: nightFile!))
        
        dayView.isHidden = false
        nightView.isHidden = true
        
        dayView.scrollView.delegate = self
        nightView.scrollView.delegate = self
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      
        let setterView = scrollView == dayView.scrollView ? nightView.scrollView : dayView.scrollView
        let getterView = scrollView
        
        setterView.zoomScale = getterView.zoomScale
        setterView.contentOffset = getterView.contentOffset
        
    }
    
}
