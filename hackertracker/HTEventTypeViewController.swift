//
//  HTEventTypeViewController.swift
//  hackertracker
//
//  Created by Seth W Law on 7/31/20.
//  Copyright © 2020 Beezle Labs. All rights reserved.
//

import UIKit

class HTEventTypeViewController: UIViewController {

    @IBOutlet weak var descriptionTextView: UITextView!

    var event_type: HTEventType?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let et = event_type {
            navigationItem.title = et.name
            descriptionTextView.text = et.description
        }

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
