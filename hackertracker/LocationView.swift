//
//  LocationView.swift
//  hackertracker
//
//  Created by Seth W Law on 7/26/22.
//  Copyright © 2022 Beezle Labs. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct LocationView: View {
    var locations: [HTLocationModel]
    let childLocations: [Int: [HTLocationModel]]

    var body: some View {
        VStack {
            List {
                ForEach(locations.filter { $0.hierDepth == 1 }.sorted { $0.hierExtentLeft < $1.hierExtentLeft }) { loc in
                    LocationCell(location: loc, childLocations: childLocations)
                }.listRowBackground(Color.clear)
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .accentColor(Color.white)
            .onAppear {
                UITableView.appearance().backgroundColor = UIColor.clear
                UITableViewCell.appearance().backgroundColor = UIColor.clear
            }
    }

    init(locations: [HTLocationModel]) {
        self.locations = locations
        childLocations = childrenLocations(locations: locations)
    }
}

struct LocationCell: View {
    var location: HTLocationModel
    var childLocations: [Int: [HTLocationModel]]
    var dfu = DateFormatterUtility.shared
    @State private var showChildren = false

    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                showChildren.toggle()
            }, label: {
                HStack(alignment: .center) {
                    if location.hierDepth != 1 {
                        Circle().foregroundColor(circleStatus(location: location))
                            .frame(width: heirCircle(heirDepth: location.hierDepth), height: heirCircle(heirDepth: location.hierDepth), alignment: .leading)
                    }
                    Text(location.shortName).font(heirFont(heirDepth: location.hierDepth)).fixedSize(horizontal: false, vertical: true).multilineTextAlignment(.leading)
                    Spacer()
                    if !(childLocations[location.id]?.isEmpty ?? false) {
                        showChildren ? Image(systemName: "chevron.down") : Image(systemName: "chevron.left")
                    }
                }.padding(.leading, CGFloat(location.hierDepth - 1) * 20.0)
            }).disabled(childLocations[location.id]?.isEmpty ?? true).buttonStyle(BorderlessButtonStyle()).foregroundColor(.white)
            if showChildren {
                ForEach(childLocations[location.id] ?? []) { loc in
                    LocationCell(location: loc, childLocations: childLocations)
                }
            }
        }
    }
}

func childrenLocations(locations: [HTLocationModel]) -> [Int: [HTLocationModel]] {
    return locations.sorted { $0.hierExtentLeft < $1.hierExtentLeft }.reduce(into: [Int: [HTLocationModel]]()) { dict, loc in
        dict[loc.id] = locations.filter { $0.parentId == loc.id }
    }
}

func circleStatus(location: HTLocationModel) -> Color {
    let schedule = location.schedule
    let curDate = Date()

    if schedule.isEmpty {
        switch location.defaultStatus {
        case "open":
            return .green
        case "closed":
            return .red
        default:
            return .gray
        }
    } else if schedule.contains(where: { $0.status == "open" && curDate >= $0.begin && curDate <= $0.end }) {
        return .green
    } else if schedule.contains(where: { $0.status == "closed" && curDate >= $0.begin && curDate <= $0.end}) {
        return .red
    } else if schedule.allSatisfy({ $0.status == "closed" }) {
        return .red
    } else {
        return .gray
    }
}

func heirCircle(heirDepth: Int) -> CGFloat {
    switch heirDepth {
    case 1:
        return 20
    case 2:
        return 17
    case 3:
        return 14
    case 4:
        return 11
    case 5:
        return 8
    default:
        return 5
    }
}

func heirFont(heirDepth: Int) -> Font {
    switch heirDepth {
    case 1:
        return Font.title.bold()
    case 2:
        return Font.headline
    case 3:
        return Font.callout
    case 4:
        return Font.subheadline
    case 5:
        return Font.body
    case 6:
        return Font.footnote
    default:
        return Font.caption
    }
}

class LocationUIView: UIViewController {
    var locationsToken: UpdateToken?
    var locations: [HTLocationModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadLocations()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let lvc = UIHostingController(rootView: LocationView(locations: locations))
        addChild(lvc)

        view.addSubview(lvc.view)
        lvc.view.translatesAutoresizingMaskIntoConstraints = false
        lvc.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        lvc.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        lvc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        lvc.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        navigationItem.title = "Locations"

        lvc.view.backgroundColor = UIColor(red: 45.0 / 255.0, green: 45.0 / 255.0, blue: 45.0 / 255.0, alpha: 1.0)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func loadLocations() {
        locationsToken = FSConferenceDataController.shared.requestLocations(forConference: AnonymousSession.shared.currentConference) { result in
            switch result {
            case let .success(locationList):
                self.locations = locationList
                self.viewDidAppear(true)
            case let .failure(error):
                NSLog("Load Locations Failure: \(error.localizedDescription)")
            }
        }
    }
}
