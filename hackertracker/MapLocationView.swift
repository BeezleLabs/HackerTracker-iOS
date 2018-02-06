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
    case training1
    case training2
    case training3
    case workshop1
    case workshop2
    case chillout
    case lightning
    case villages
    
    public static func valueFromString(_ value : String) -> Location
    {
        switch value.lowercased() {
        case "track one":
            return .track1
        case "track two":
            return .track2
        case "villages":
            return .villages
        case "training one":
            return .training1
        case "training two":
            return .training2
        case "training three":
            return .training3
        case "workshop one":
            return .workshop1
        case "workshop two":
            return .training2
        case "chill out":
            return .chillout
        case "Lightning":
            return .lightning
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
        calendar.timeZone = TimeZone(abbreviation: "EST")!
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
    
    fileprivate static let dayFile = Bundle.main.url(forResource: "hackwest-2018-map", withExtension: "pdf")!
    fileprivate static let nightFile = Bundle.main.url(forResource: "hackwest-2018-map", withExtension: "pdf")!

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
            case .training1:
                mapZoomLevel = 5.32341261928717
                mapOffset = CGPoint(x: 50.0, y: 287.0)
                break
            case .training2:
                mapZoomLevel = 5.32341261928717
                mapOffset = CGPoint(x: 50.0, y: 730.0)
                break
            case .training3:
                mapZoomLevel = 5.32341261928717
                mapOffset = CGPoint(x: 275.0, y: 675.0)
                break
            case .workshop1:
                mapZoomLevel = 5.32341261928717
                mapOffset = CGPoint(x: 555.0, y: 712.0)
                break
            case .workshop2:
                mapZoomLevel = 5.32341261928717
                mapOffset = CGPoint(x: 307.0, y: 287.0)
                break
            case .track1:
                mapZoomLevel = 4.0
                mapOffset = CGPoint(x: 796.0, y: 475.0)
                break
            case .track2:
                mapZoomLevel = 5.0
                mapOffset = CGPoint(x: 925, y: 239)
                break
            case .chillout:
                mapZoomLevel = 5.32341261928717
                mapOffset = CGPoint(x: 943.0, y: 282.0)
                break
            case .villages:
                mapZoomLevel = 5.32341261928717
                mapOffset = CGPoint(x: 1456.0, y: 276.0)
                break
            case .lightning:
                mapZoomLevel = 5.32341261928717
                mapOffset = CGPoint(x: 950.0, y: 792.0)
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
