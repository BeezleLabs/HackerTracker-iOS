//
//  HTEventTypeViewController.swift
//  hackertracker
//
//  Created by Seth W Law on 7/31/20.
//  Copyright © 2020 Beezle Labs. All rights reserved.
//

import UIKit

class HTEventTypeViewController: UIViewController {
    @IBOutlet private var descriptionTextView: UITextView!

    var eventType: HTEventType?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let eventType = eventType {
            navigationItem.title = eventType.name
            descriptionTextView.text = eventType.description
        }
    }
}
