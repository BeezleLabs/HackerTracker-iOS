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
    let hackerAnimationDuration = 4.0

    private var timerUp = false
    private var importComplete = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName:"Status")
        fr.returnsObjectsAsFaults = false
        
        let status = try! context.fetch(fr) as NSArray

        // TODO: Only play animation on first launch.
        var timeBeforeSegue = 1.0
        timeBeforeSegue = hackerAnimationDuration + 0.5
        playAnimation()

        if status.count < 1 {
            NSLog("Database not setup, preloading with initial schedule")
            self.loadData()
        } else {
            importComplete = true
        }

        Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(HTInitViewController.timerComplete), userInfo: nil, repeats: false)
    }
    
    func loadData() {
        let context = getBackgroundContext()
        
        context.perform { 
            
            let dataManager = DataImportManager(managedContext: context)
            
            let speakers_file = Bundle.main.path(forResource: "speakers", ofType: "json")!
            let speakers_content = try! String(contentsOfFile: speakers_file)
            let speakers_data = speakers_content.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            
            do {
               try dataManager.importSpeakers(speakerData: speakers_data)
            } catch {
                print("Failed to import Speakers")
            }
            
            let schedule_file = Bundle.main.path(forResource: "schedule-full", ofType: "json")!
            let schedule_content = try! NSString(contentsOfFile: schedule_file, encoding: String.Encoding.ascii.rawValue)
            let schedule_data = schedule_content.data(using: String.Encoding.utf8.rawValue)!
            
            do {
                try dataManager.importEvents(eventData: schedule_data)
            } catch {
                print("Failed to import schedule")
            }
            
            let message1 = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
            message1.date = Date()
            message1.msg = "Welcome to HackerTracker iOS for DEF CON 25. If you have any events, parties, or contests to add, or if you find any errors or typos, email info@beezle.org. The HackerTracker team is now a part of the DEF CON Infobooth. Code for this app can be found at https://github.com/BeezleLabs/HackerTracker-iOS."
            
            let message2 = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
            message2.date = Date()
            message2.msg = "The initial schedule contains official talks, workshops, villages, parties, etc. Pull down on the schedule to update with info.defcon.org."
            
            do {
                try context.save()
            } catch let error as NSError {
                NSLog("error: \(error)")
            }
            
            DispatchQueue.main.async {
                self.importComplete = true
                self.go()
            }
        }

    }
    
    func timerComplete()
    {
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
        if importComplete && timerUp
        {
            self.performSegue(withIdentifier: "HTHomeSegue", sender: self)
        }
    }

}
