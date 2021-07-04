//
//  MapLocationView.swift
//  hackertracker
//
//  Created by Christopher Mays on 7/9/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit

enum Location: String, CaseIterable {
    case track1 = "track 1"
    case track2 = "track 2"
    case track3 = "track 3"
    case track101 = "101 track"
    case icona = "icon a"
    case iconb = "icon b"
    case iconc = "icon c"
    case icond = "icon d"
    case icone = "icon e"
    case iconf = "icon f"
    case demolabs = "demo labs"
    case chillout
    case contest = "contest area"
    case skytalks
    case aivillage = "ai village"
    case hhv = "hardware hacking"
    case blueteam = "blue team"
    case wireless = "wireless village"
    case ethics = "ethics village"
    case cpv = "crypto & privacy"
    case ics = "ics village"
    case sev = "social engineer"
    case iot = "iot village"
    case recon = "recon village"
    case chv
    case vxv = "vx (chip-off) village"
    case caadv = "caad village"
    case ddv = "data duplication"
    case r00tz
    case phv = "packet hacking"
    case cannabis
    case vendor = "vendor area"
    case bio
    case unknown

    static func valueFromString(_ value: String) -> Location {
        let value = value.lowercased()
        return .allCases.first(where: { value.contains($0.rawValue) }) ?? .unknown
    }
}

enum TimeOfDay {
    case day
    case night

    func url() -> URL {
        return MapLocationView.caesarsFile as URL
    }

    static func timeOfDay(for date: Date) -> TimeOfDay {
        var calendar = NSCalendar.current
        calendar.timeZone = TimeZone(abbreviation: "PST") ?? TimeZone.current
        let hour = calendar.component(.hour, from: date)
        // 8pm
        return hour >= 20 ? .night : .day
    }
}

enum MapFile {
    case caesars
    case flamingo
    case flamnight
    case linq

    /*static func mapFile(_ l: Location) -> URL {
        if l == .track101 || l == .blueteam || l == .cannabis || l == .chv || l == .caadv || l == .skytalks || l == .ics
        {
            return Bundle.main.url(forResource: "dc-26-flamingo-public-1", withExtension: "pdf", subdirectory: "maps")!
        } else if l == .icona || l == .iconb || l == .iconc || l == .icond || l == .icone || l == .iconf {
            return Bundle.main.url(forResource: "dc-26-linq-workshops", withExtension: "pdf", subdirectory: "maps")!
        } else {
            return Bundle.main.url(forResource: "dc-26-caesars-public-1", withExtension: "pdf", subdirectory: "maps")!
        }
    }*/
}

class MapLocationView: UIView, UIWebViewDelegate, UIScrollViewDelegate {
    let webView = UIWebView()

    var currentIntrinsizeContentSize = CGSize(width: 0, height: 0)
    var mapOffset = CGPoint(x: 0, y: 0)
    var mapZoomLevel: CGFloat = 1.0

    fileprivate static let caesarsFile = Bundle.main.url(forResource: "dc-26-caesars-public-1", withExtension: "pdf", subdirectory: "maps")!
    fileprivate static let flamDayFile = Bundle.main.url(forResource: "dc-26-flamingo-public-1", withExtension: "pdf", subdirectory: "maps")!
    fileprivate static let flamNightFile = Bundle.main.url(forResource: "dc-26-flamingo-noct-public", withExtension: "pdf", subdirectory: "maps")!
    fileprivate static let linqFile = Bundle.main.url(forResource: "dc-26-linq-workshops", withExtension: "pdf", subdirectory: "maps")!

    var currentLocation: Location = .unknown {
        didSet {
            switch currentLocation {
            case .track1:
                mapZoomLevel = 4.0
                mapOffset = CGPoint(x: 750.0, y: 750.0)
            case .track2:
                mapZoomLevel = 4.0
                mapOffset = CGPoint(x: 100, y: 250)
            case .track3:
                mapZoomLevel = 4.0
                mapOffset = CGPoint(x: 100, y: 675)
            case .track101:
                mapZoomLevel = 2.5
                mapOffset = CGPoint(x: 10.0, y: 275.0)
            case .icona:
                mapZoomLevel = 3.0
                mapOffset = CGPoint(x: 275, y: 450)
            case .iconb:
                mapZoomLevel = 3.0
                mapOffset = CGPoint(x: 275, y: 450)
            case .iconc:
                mapZoomLevel = 3.0
                mapOffset = CGPoint(x: 425, y: 450)
            case .icond:
                mapZoomLevel = 3.0
                mapOffset = CGPoint(x: 425, y: 475)
            case .icone:
                mapZoomLevel = 3.0
                mapOffset = CGPoint(x: 450, y: 475)
            case .iconf:
                mapZoomLevel = 3.0
                mapOffset = CGPoint(x: 100, y: 525)
            case .demolabs:
                mapZoomLevel = 4.0
                mapOffset = CGPoint(x: 650, y: 712.0)
            case .skytalks:
                mapZoomLevel = 3.0
                mapOffset = CGPoint(x: 250, y: 800)
            case .contest:
                mapZoomLevel = 4.0
                mapOffset = CGPoint(x: 680, y: 200)
            case .aivillage:
                mapZoomLevel = 4.0
                mapOffset = CGPoint(x: 500, y: 775)
            case .hhv:
                mapZoomLevel = 4.0
                mapOffset = CGPoint(x: 50, y: 725)
            case .blueteam:
                mapZoomLevel = 3.0
                mapOffset = CGPoint(x: 500, y: 800)
            case .wireless:
                mapZoomLevel = 4.0
                mapOffset = CGPoint(x: 400, y: 200)
            case .ethics:
                mapZoomLevel = 4.0
                mapOffset = CGPoint(x: 400, y: 575)
            case .cpv:
                mapZoomLevel = 4.0
                mapOffset = CGPoint(x: 400, y: 200)
            case .ics:
                mapZoomLevel = 3.0
                mapOffset = CGPoint(x: 475, y: 275)
            case .cannabis:
                mapZoomLevel = 3.0
                mapOffset = CGPoint(x: 175, y: 225)
            case .sev:
                mapZoomLevel = 4.0
                mapOffset = CGPoint(x: 200, y: 287.0)
            case .iot:
                mapZoomLevel = 4.0
                mapOffset = CGPoint(x: 400, y: 475)
            case .bio:
                mapZoomLevel = 4.0
                mapOffset = CGPoint(x: 400, y: 475)
            case .recon:
                mapZoomLevel = 4.0
                mapOffset = CGPoint(x: 400, y: 900)
            case .vxv:
                mapZoomLevel = 5.0
                mapOffset = CGPoint(x: 300, y: 750)
            case .caadv:
                mapZoomLevel = 3.0
                mapOffset = CGPoint(x: 175, y: 225)
            case .ddv:
                mapZoomLevel = 5.0
                mapOffset = CGPoint(x: 500, y: 1100)
            case .r00tz:
                mapZoomLevel = 4.0
                mapOffset = CGPoint(x: 400, y: 200)
            case .vendor:
                mapZoomLevel = 4.0
                mapOffset = CGPoint(x: 200.0, y: 275.0)
            case .phv:
                mapZoomLevel = 4.0
                mapOffset = CGPoint(x: 400, y: 200)
            case .chillout:
                mapZoomLevel = 5.0
                mapOffset = CGPoint(x: 625, y: 950)
            default:
                mapOffset = .zero
            }

            if currentLocation == .unknown {
                currentIntrinsizeContentSize = CGSize(width: 0, height: 0)
            } else {
                currentIntrinsizeContentSize = CGSize(width: 300, height: 300)
            }

            invalidateIntrinsicContentSize()
        }
    }

    init (location: Location) {
        super.init(frame: CGRect.zero)

        currentLocation = location
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    func setup() {
        addSubview(webView)

        webView.isUserInteractionEnabled = false
        webView.translatesAutoresizingMaskIntoConstraints = false

        webView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        // webView.loadRequest(URLRequest(url: MapFile.mapFile(currentLocation)))
        webView.delegate = self
        webView.scalesPageToFit = true
        webView.scrollView.delegate = self
        webView.scrollView.scrollsToTop = false
    }

    override var intrinsicContentSize: CGSize {
        return currentIntrinsizeContentSize
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.scrollView.zoomScale = mapZoomLevel
        webView.scrollView.contentOffset = mapOffset
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}
