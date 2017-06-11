//
//  HTMapsViewController.swift
//  hackertracker
//
//  Created by Seth Law on 5/11/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit

class HTMapsViewController: UIViewController, UIScrollViewDelegate {


    @IBOutlet weak var mapView: MapView!
    @IBOutlet weak var sizingView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
   
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var initialScale: CGFloat = 0.0
    var currentScale: CGFloat = 1.0

    var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        
        sizingView.frame = CGRect(x: 0, y: 0, width: 475, height: 535)
        mapView.frame = CGRect(x: 0, y: 0, width: 475, height: 535)
        
        sizingView.center = CGPoint(x:self.scrollView.bounds.midX, y: self.scrollView.bounds.midY)
        mapView.center = sizingView.center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sizingView.center = CGPoint(x:self.scrollView.bounds.midX, y: self.scrollView.bounds.midY)
        mapView.center = sizingView.center
        
        scrollView.contentSize = sizingView.frame.size
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mapView;
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        mapView.setNeedsDisplay()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentSize = mapView.frame.size
        
        if (scrollView.zoomScale < 1)
        {
            mapView.center = scrollView.center
        }
    }

}
