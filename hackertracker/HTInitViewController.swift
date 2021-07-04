//
//  HTInitViewController.swift
//  hackertracker
//
//  Created by Seth Law on 3/30/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class HTInitViewController: UIViewController, HTConferenceTableViewControllerDelegate {

    @IBOutlet weak var splashView: UIImageView!
    let hackerAnimationDuration = 2.0

    private var timerUp = false
    private var importComplete = false
    private var token: AnyObject?

    override func viewDidLoad() {
        super.viewDidLoad()

        playAnimation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadCon()
    }

    func loadCon() {
        if let conCode = UserDefaults.standard.string(forKey: "conference") {
            AnonymousSession.initialize(conCode: conCode) { (session) in
                if let _ = session {
                    self.timerComplete()
                } else {
                    self.displayConferencePicker()
                }
            }
        } else {
            displayConferencePicker()
        }
    }

    func displayConferencePicker() {
        if let currentViewController = storyboard?.instantiateViewController(withIdentifier: "HTConferenceTableViewController") as? HTConferenceTableViewController {
            currentViewController.delegate = self
            self.present(currentViewController, animated: true, completion: nil)
        }
    }

    func didSelect(conference: ConferenceModel) {
        self.dismiss(animated: true, completion: nil)
        loadCon()
    }

    @objc func timerComplete() {
        timerUp = true
        go()
    }

    func playAnimation() {
        let animation = Animation(duration: hackerAnimationDuration, image: splashView.image!) { (image) in
            self.splashView.image = image
        }

        animation.startHackerAnimation()
    }

    func go() {
        if timerUp {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "HTHamburgerMenuViewController") as? HTHamburgerMenuViewController {
                let kw = UIApplication.shared.windows.first { $0.isKeyWindow }
                kw?.rootViewController = vc
            }
        }
    }

}
