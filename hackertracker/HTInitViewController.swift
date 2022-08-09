//
//  HTInitViewController.swift
//  hackertracker
//
//  Created by Seth Law on 3/30/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import CoreData
import Firebase
import UIKit

class HTInitViewController: UIViewController, HTConferenceTableViewControllerDelegate {
    @IBOutlet private var splashView: UIImageView!
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
            AnonymousSession.initialize(conCode: conCode) { session in
                if session != nil {
                    self.timerComplete()
                } else {
                    self.displayConferencePicker()
                }
            }
        } else {
            UserDefaults.standard.set("Information", forKey: "startScreen")
            displayConferencePicker()
        }
    }

    func displayConferencePicker() {
        if let currentViewController = storyboard?.instantiateViewController(withIdentifier: "HTConferenceTableViewController") as? HTConferenceTableViewController {
            currentViewController.delegate = self
            self.present(currentViewController, animated: true)
        }
    }

    func didSelect(conference: ConferenceModel) {
        self.dismiss(animated: true)
        loadCon()
    }

    @objc func timerComplete() {
        timerUp = true
        go()
    }

    func playAnimation() {
        guard let image = splashView.image else { return }
        let animation = Animation(duration: hackerAnimationDuration, image: image) { image in
            self.splashView.image = image
        }

        animation.startHackerAnimation()
    }

    func go() {
        if timerUp {
            if let controller = storyboard?.instantiateViewController(withIdentifier: "HTHamburgerMenuViewController") as? HTHamburgerMenuViewController {
                let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
                keyWindow?.rootViewController = controller
            }
        }
    }
}
