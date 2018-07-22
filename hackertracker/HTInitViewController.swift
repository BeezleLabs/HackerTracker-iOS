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
        
        let dc26_update = DateFormatterUtility.yearMonthDayFormatter.date(from: "2018-07-01")
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName:"Status")
        fr.returnsObjectsAsFaults = false
        
        let status = try! context.fetch(fr) as! [Status]

        let timeBeforeSegue = hackerAnimationDuration
        playAnimation()

        if status.count < 1 {
            NSLog("Database not setup, preloading with initial schedule")
            self.loadData()
            do {
                try DataImportManager(managedContext: context).setSyncDate(Date())
                try context.save()
            } catch {
                NSLog("Error setting sync date: \(error)")
            }
        } else if (status[0].lastsync! < dc26_update!) {
            NSLog("Database older than dc26 update, resetting")
            do {
                try DataImportManager(managedContext: context).resetDB()
                try context.save()
            } catch {
                NSLog("Error resetting the database \(error)")
            }
            self.loadData()
        } else {
            importComplete = true
        }

        Timer.scheduledTimer(timeInterval: TimeInterval(timeBeforeSegue), target: self, selector: #selector(HTInitViewController.timerComplete), userInfo: nil, repeats: false)
    }
    
    func loadData() {
            let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.backgroundManagedObjectContext!
            
            context.perform {
                
                let dataManager = DataImportManager(managedContext: context)
                let requestManager = DataRequestManager(managedContext: context)
                let dir: String = "DC26"
                // If we are loading data, it's the initial load, so specify which conference we should load by the conference code
                
                let conferences_file = Bundle.main.path(forResource: "conferences", ofType: "json")!
                let conferences_content = try! String(contentsOfFile: conferences_file)
                let conferences_data = conferences_content.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
                do {
                    try _ = dataManager.importConferences(conData: conferences_data)
                } catch {
                    print("Failed to import conferences: \(error)")
                }
                let myCon = requestManager.getConference(dir)!
                myCon.selected = true
                
                for i in ["articles","event_types", "faqs", "locations", "notifications", "speakers", "vendors", "events"] {
                    let a_file = Bundle.main.path(forResource: i, ofType: "json", inDirectory: dir)!
                    let a_content = try! String(contentsOfFile: a_file)
                    let a_data = a_content.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
                    do {
                        try dataManager.importData(data: a_data)
                    } catch {
                        print("Failed to import \(i): \(error)")
                    }

                }
                
                do {
                    try context.save()
                } catch let error as NSError {
                    NSLog("error: \(error)")
                }
            

                self.importComplete = true
                DispatchQueue.main.async {
                    self.go()
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
        if importComplete && timerUp {
            self.performSegue(withIdentifier: "HTHomeSegue", sender: self)
        }
    }

}
