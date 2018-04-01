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
        
        let shmoo_update = DateFormatterUtility.yearMonthDayFormatter.date(from: "2018-01-15")
        let hw_update = DateFormatterUtility.yearMonthDayFormatter.date(from: "2018-04-01")
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName:"Status")
        fr.returnsObjectsAsFaults = false
        
        let status = try! context.fetch(fr) as! [Status]

        let timeBeforeSegue = hackerAnimationDuration
        playAnimation()

        if status.count < 1 {
            NSLog("Database not setup, preloading with initial schedule")
            self.loadData()
        } else if (status[0].lastsync < shmoo_update!) {
            NSLog("Database older than shmoo update, resetting")
            do {
                try DataImportManager(managedContext: context).deleteMessages()
                try context.save()
            } catch {
                NSLog("Error deleting old messages")
            }
            self.loadData()
        } else if (status[0].lastsync < hw_update!) {
            NSLog("Database older than most recent update, resetting")
            do {
                try DataImportManager(managedContext: context).deleteMessages()
                try DataImportManager(managedContext: context).resetDB()
                try context.save()
            } catch {
                NSLog("Error deleting old messages")
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
                
                let speakers_file = Bundle.main.path(forResource: "speakers", ofType: "json")!
                let speakers_content = try! String(contentsOfFile: speakers_file)
                let speakers_data = speakers_content.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
                
                do {
                    try dataManager.importSpeakers(speakerData: speakers_data)
                } catch {
                    print("Failed to import speakers: \(error)")
                }
                
                let schedule_file = Bundle.main.path(forResource: "schedule-full", ofType: "json")!
                let schedule_content = try! String(contentsOfFile: schedule_file)
                let schedule_data = schedule_content.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
                
                do {
                    try dataManager.importEvents(eventData: schedule_data)
                } catch {
                    print("Failed to import schedule: \(error)")
                }
                
                let messages_file = Bundle.main.path(forResource: "messages", ofType: "json")!
                let messages_content = try! String(contentsOfFile: messages_file)
                let messages_data = messages_content.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
                
                do {
                    try dataManager.importMessages(msgData: messages_data)
                } catch {
                    print("Failed to import messages: \(error)")
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
