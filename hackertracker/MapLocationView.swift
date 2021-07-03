//
//  MapLocationView.swift
//  hackertracker
//
//  Created by Christopher Mays on 7/9/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit
import WebKit

public enum Location {
    case unknown
    case track1
    case track2
    case track3
    case track101
    case icona
    case iconb
    case iconc
    case icond
    case icone
    case iconf
    case demolabs
    case chillout
    case contest
    case skytalks
    case aivillage
    case hhv
    case blueteam
    case wireless
    case ethics
    case cpv
    case ics
    case sev
    case iot
    case recon
    case chv
    case vxv
    case caadv
    case ddv
    case r00tz
    case phv
    case cannabis
    case vendor
    case bio

    public static func valueFromString(_ value: String) -> Location {
        let lc = value.lowercased()
        if lc.contains("track 1") {
            return .track1
        } else if lc.contains("track 2") {
            return .track2
        } else if lc.contains("track 3") {
            return .track3
        } else if lc.contains("101 track") {
            return .track101
        } else if lc.contains("icon a") {
            return .icona
        } else if lc.contains("icon b") {
            return .iconb
        } else if lc.contains("icon c") {
            return .iconc
        } else if lc.contains("icon d") {
            return .icond
        } else if lc.contains("icon e") {
            return .icone
        } else if lc.contains("icon f") {
            return .iconf
        } else if lc.contains("demo labs") {
            return .demolabs
        } else if lc.contains("skytalks") {
            return .skytalks
        } else if lc.contains("contest area") {
            return .contest
        } else if lc.contains("ai village") {
            return .aivillage
        } else if lc.contains("hardware hacking") {
            return .hhv
        } else if lc.contains("blue team") {
            return .blueteam
        } else if lc.contains("wireless village") {
            return .wireless
        } else if lc.contains("ethics village") {
            return .ethics
        } else if lc.contains("crypto & privacy") {
            return .cpv
        } else if lc.contains("ics village") {
            return .ics
        } else if lc.contains("cannabis") {
            return .cannabis
        } else if lc.contains("social engineer") {
            return .sev
        } else if lc.contains("iot village") {
            return .iot
        } else if lc.contains("recon village") {
            return .recon
        } else if lc.contains("vx (chip-off) village") {
            return .vxv
        } else if lc.contains("caad village") {
            return .caadv
        } else if lc.contains("data duplication") {
            return .ddv
        } else if lc.contains("r00tz") {
            return .r00tz
        } else if lc.contains("vendor area") {
            return .vendor
        } else if lc.contains("packet hacking") {
            return .phv
        } else if lc.contains("bio") {
            return .bio
        } else if lc.contains("chillout") {
            return .chillout
        } else {
            return .unknown
        }

    }
}

enum TimeOfDay {
    case day
    case night

    public func url() -> URL {
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

class MapLocationView: UIView, WKNavigationDelegate {

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

    public init(location: Location) {
        super.init(frame: CGRect.zero)

        currentLocation = location
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    func setup() {
        let userScript = WKUserScript(source: """
        var meta = document.createElement('meta');
        meta.setAttribute('name', 'viewport');
        meta.setAttribute('content', 'width=device-width');
        document.getElementsByTagName('head')[0].appendChild(meta);
        """, injectionTime: .atDocumentEnd, forMainFrameOnly: true)

        let contentController = WKUserContentController()
        contentController.addUserScript(userScript)

        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: webConfiguration)

        addSubview(webView)

        webView.isUserInteractionEnabled = false
        webView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        // webView.loadRequest(URLRequest(url: MapFile.mapFile(currentLocation)))
        webView.navigationDelegate = self
        webView.scrollView.scrollsToTop = false
    }

    override var intrinsicContentSize: CGSize {
        get {
            return currentIntrinsizeContentSize
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        webView.scrollView.zoomScale = mapZoomLevel
        webView.scrollView.contentOffset = mapOffset
    }
}
