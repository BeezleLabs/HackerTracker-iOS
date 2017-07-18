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
    case track_101
    case track1_101
    case track2_101
    case track2
    case track3
    case track4
    case trevi
    case capri
    case modena
    case bioHackingVillage
    case cryptoAndPrivacyVillage
    case hardwareHackingVillage
    case icsVillage
    case iotVillage
    case lockpickVillage
    case packetCaptureVillage
    case socialEngineerVillage
    case tamperEvidentVillage
    case wirelessVillage
    
    public static func valueFromString(_ value : String) -> Location
    {
        switch value.lowercased() {
        case "101 track 1":
            return .track1_101
        case "101 track 2":
            return .track2_101
        case "101 track":
            return .track_101
        case "track 3":
            return .track3
        case "track 4":
            return .track4
        case "trevi room":
            return .trevi
        case "capri room":
            return .capri
        case "modena room":
            return .modena
        case "track 2":
            return .track2
        case "BIO Hacking Village":
            return .bioHackingVillage
        case "Crypto and Privacy Village":
            return .cryptoAndPrivacyVillage
        case "Hardware Hacking Village":
            return .hardwareHackingVillage
        case "ICS Village":
            return .icsVillage
        case "IoT Village":
            return .iotVillage
        case "Lockpick Village":
            return .lockpickVillage
        case "Packet Capture Village":
            return .packetCaptureVillage
        case "Social-Engineer Village":
            return .socialEngineerVillage
        case "Tamper Evident Village":
            return .tamperEvidentVillage
        case "Wireless Village":
            return .wirelessVillage
        default:
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
    
    fileprivate static let dayFile = Bundle.main.url(forResource: "dc-25-floorplan-v7.5-public", withExtension: "pdf")!
    fileprivate static let nightFile = Bundle.main.url(forResource: "dc-25-floorplan-night", withExtension: "pdf")!

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
            case .track_101, .track1_101:
                mapZoomLevel = 5.46535710851014
                mapOffset = CGPoint(x: 1108.0, y: 1091.0)
                break
            case .track2, .track2_101:
                mapZoomLevel = 5.04600641912036
                mapOffset = CGPoint(x: 936.333333333333, y: 352)
                break
            case .track3:
                mapZoomLevel = 6.47638274448022
                mapOffset = CGPoint(x: 281, y: 586.333333333333)
                break
            case .track4:
                mapZoomLevel = 6.47638274448022
                mapOffset = CGPoint(x: 441.666666666667, y: 586.333333333333)
                break
            case .trevi:
                mapZoomLevel = 30.5747421643601
                mapOffset = CGPoint(x: 4134.66666666667, y: 4805.66666666667)
                break
            case .modena:
                mapZoomLevel = 30.5747421643601
                mapOffset = CGPoint(x: 4086.66666666667, y: 5467.33333333333)
                break
            case .capri:
                mapZoomLevel = 25.7730198429929
                mapOffset = CGPoint(x: 3129.0, y: 6295.0)
                break
            case .bioHackingVillage:
                mapZoomLevel = 15.5319305068955
                mapOffset = CGPoint(x: 1824.0, y: 2302.0)
                break
            case .cryptoAndPrivacyVillage:
                mapZoomLevel = 11.5321488259658
                mapOffset = CGPoint(x: 1756.66666666667, y: 2700.33333333333)
                break
            case .hardwareHackingVillage
                mapZoomLevel = 5.99026466659583
                mapOffset = CGPoint(x: 295.666666666667, y: 1173.66666666667)
                break
            case .icsVillage:
                mapZoomLevel = 13.9902143693864
                mapOffset = CGPoint(x: 392.666666666667, y: 2656.66666666667)
                break
            case .iotVillage:
                mapZoomLevel = 13.9902143693864
                mapOffset = CGPoint(x: 392.666666666667, y: 2838.33333333333)
                break
            case .lockpickVillage:
                mapZoomLevel = 7.55686887825483
                mapOffset = CGPoint(x: 240.0, y: 1466.0)
                break
            case .packetCaptureVillage:
                mapZoomLevel = 4.78024461014065
                mapOffset = CGPoint(x: 542.333333333333, y: 246.666666666667)
                break
            case .socialEngineerVillage:
                mapZoomLevel = 9.11508857992245
                mapOffset = CGPoint(x: 1729.66666666667, y: 1392.0)
                break
            case .tamperEvidentVillage:
                mapZoomLevel = 7.15414767702267
                mapOffset = CGPoint(x: 257.333333333333, y: 1487.33333333333)
                break
            case .wirelessVillage:
                mapZoomLevel = 11.5321488259658
                mapOffset = CGPoint(x: 1615.66666666667, y: 2700.33333333333)
                break
            default:
                mapOffset = .zero
                currentIntrinsizeContentSize = CGSize(width: 0, height: 0)
                break
            }

            currentIntrinsizeContentSize = CGSize(width: 300, height: 300)
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
