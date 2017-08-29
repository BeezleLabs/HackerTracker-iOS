//
//  MapLocationView.swift
//  hackertracker
//
//  Created by Christopher Mays on 7/9/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit

public enum Location
{
    case unknown
    case track1
    case track2
    case seminars
    
    public static func valueFromString(_ value : String) -> Location
    {
        switch value.lowercased() {
        case "track 1":
            return .track1
        case "track 2":
            return .track2
        case "seminars":
            return .seminars
        default:
            print("unkown location: \(value)")
            return .unknown
        }
    }
}


enum TimeOfDay
{
    case day
    case night
    
    public func url() -> URL
    {
        return (self == .day ? MapLocationView.dayFile : MapLocationView.nightFile) as URL
    }

    static func timeOfDay(for date: Date) -> TimeOfDay {
        var calendar = NSCalendar.current
        calendar.timeZone = TimeZone(abbreviation: "PDT")!
        let hour = calendar.component(.hour, from: date)
        // 8pm
        return hour >= 20 ? .night : .day

    }
}


class MapLocationView: UIView, UIWebViewDelegate, UIScrollViewDelegate {

    let webView = UIWebView()

    var currentIntrinsizeContentSize = CGSize(width:0, height:0)
    var mapOffset = CGPoint(x:0, y:0)
    var mapZoomLevel : CGFloat = 1.0
    
    fileprivate static let dayFile = Bundle.main.url(forResource: "toorcon-19-floorplan", withExtension: "pdf")!
    fileprivate static let nightFile = Bundle.main.url(forResource: "toorcon-19-floorplan", withExtension: "pdf")!

    var timeOfDay = TimeOfDay.day
    {
        didSet
        {
            webView.loadRequest(URLRequest(url: timeOfDay.url()))
        }
    }
    
    var currentLocation : Location = .unknown
    {
        didSet
        {
            switch currentLocation {
            case .track1:
                mapZoomLevel = 8.32341261928717
                mapOffset = CGPoint(x: 334.5, y: 641.5)
                break
            case .track2:
                mapZoomLevel = 10.2361423152965
                mapOffset = CGPoint(x: 1107.0, y: 756.5)
                break
            case .seminars:
                mapZoomLevel = 10.2361423152965
                mapOffset = CGPoint(x: 502.0, y: 1329.0)
                break
            default:
                mapOffset = .zero
                break
            }

            if (currentLocation == .unknown) {
                currentIntrinsizeContentSize = CGSize(width: 0, height: 0)
            } else {
                currentIntrinsizeContentSize = CGSize(width: 300, height: 300)
            }
            
            invalidateIntrinsicContentSize()
        }
    }
    
    public init (location : Location) {
        super.init(frame: CGRect.zero)
       
        currentLocation = location
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    
    
    func setup()
    {
        addSubview(webView)
        
        webView.isUserInteractionEnabled = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        webView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        webView.loadRequest(URLRequest(url: timeOfDay.url()))
        webView.delegate = self
        webView.scalesPageToFit = true
        webView.scrollView.delegate = self
        webView.scrollView.scrollsToTop = false
    }
    
    
    
    override var intrinsicContentSize: CGSize {
        get
        {
            return currentIntrinsizeContentSize
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        webView.scrollView.zoomScale = mapZoomLevel
        webView.scrollView.contentOffset = mapOffset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset)
        print(scrollView.zoomScale)
    }

}
