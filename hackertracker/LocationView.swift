//
//  LocationView.swift
//  hackertracker
//
//  Created by Seth W Law on 7/26/22.
//  Copyright © 2022 Beezle Labs. All rights reserved.
//

import SwiftUI
import UIKit

struct LocationView: View {
    var body: some View {
        // ScrollView {
            VStack {
                Text("Location Status!")
                    .font(.title)
                    .foregroundColor(.white)
                Text("something else goes here")
                    .font(.caption)
                    .foregroundColor(.white)
            }
        // }
    }
}

struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationView()
    }
}

class LocationUIView: UIViewController {
    let lvc = UIHostingController(rootView: LocationView())

    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("LocationUIView viewDidLoad")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NSLog("LocationUIView viewDidAppear")

        self.addChild(lvc)
        // lvc.view.translatesAutoresizingMaskIntoConstraints = false
        lvc.view.frame = view.frame
        // lvc.view.autoresizingMask = .
        NSLog("LocationUIView: Frame size is \(view.frame.height)x\(view.frame.width)")
        /* lvc.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        lvc.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        lvc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        lvc.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true */

        view.addSubview(lvc.view)
        lvc.view.backgroundColor = UIColor(red: 45.0 / 255.0, green: 45.0 / 255.0, blue: 45.0 / 255.0, alpha: 1.0)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
