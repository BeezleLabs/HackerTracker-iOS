//
//  HTMapsViewController.swift
//  hackertracker
//
//  Created by Seth Law on 5/11/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit

class HTMapsViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollview: UIScrollView!
    
    var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image:UIImage
        
        let path = NSBundle.mainBundle().pathForResource("dc-24-fp-final", ofType: "png")
        if (path != nil) {
            image = UIImage(contentsOfFile: path!)!
            imageView = UIImageView(image: image)
            imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size:image.size)
            scrollview.addSubview(imageView)
            
            scrollview.contentSize = image.size
        }
        //let image = UIImage(named: "map-hotel.png")!
        /*imageView = UIImageView(image: image)
        imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size:image.size)
        scrollview.addSubview(imageView)
        
        scrollview.contentSize = image.size*/
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(HTMapsViewController.scrollViewDoubleTapped(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollview.addGestureRecognizer(doubleTapRecognizer)
        
        let scrollViewFrame = scrollview.frame
        let scaleWidth = scrollViewFrame.size.width / scrollview.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollview.contentSize.height
        let minScale = min(scaleWidth, scaleHeight);
        scrollview.minimumZoomScale = minScale;
        
        scrollview.maximumZoomScale = 1.0
        scrollview.zoomScale = minScale;
        
        centerScrollViewContents()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centerScrollViewContents() {
        let boundsSize = scrollview.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        imageView.frame = contentsFrame
    }
    
    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.locationInView(imageView)
        
        var newZoomScale = scrollview.zoomScale * 1.5
        newZoomScale = min(newZoomScale, scrollview.maximumZoomScale)
        
        let scrollViewSize = scrollview.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectToZoomTo = CGRectMake(x, y, w, h);
        
        scrollview.zoomToRect(rectToZoomTo, animated: true)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
