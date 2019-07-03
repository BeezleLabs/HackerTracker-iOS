//
//  HTInitViewController.swift
//  hackertracker
//
//  Created by Seth Law on 3/30/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class HTInitViewController: UIViewController {

    @IBOutlet weak var splashView: UIImageView!
    let hackerAnimationDuration = 2.0

    private var timerUp = false
    private var importComplete = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        let dfu = DateFormatterUtility.shared
        if let tz = DataRequestManager(managedContext: context).getSelectedConference()?.timezone {
            dfu.update(identifier: tz)
        }

        let timeBeforeSegue = hackerAnimationDuration
        playAnimation()

        /*if status.count < 1 {
            NSLog("Database not setup, preloading with initial schedule")
            //self.loadData()
            do {
                try DataImportManager(managedContext: context).setSyncDate(Date())
                try context.save()
            } catch {
                NSLog("Error setting sync date: \(error)")
            }
        } else {
            importComplete = true
        } */

        Timer.scheduledTimer(timeInterval: TimeInterval(timeBeforeSegue), target: self, selector: #selector(timerComplete), userInfo: nil, repeats: false)
    }
    
    func loadData() {
            let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let db = delegate.db!
        
            let conferences = db.collection("conferences").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        NSLog("\(document.documentID) => \(document.data())")
                    }
                }
            }
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
            self.performSegue(withIdentifier: "HTHomeSegue", sender: self)
        }
    }

}
