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
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName:"Status")
        fr.returnsObjectsAsFaults = false
        
        let status = try! context.fetch(fr) as NSArray

        let timeBeforeSegue = hackerAnimationDuration
        playAnimation()

        if status.count < 1 {
            NSLog("Database not setup, preloading with initial schedule")
            self.loadData()
        } else {
            importComplete = true
        }

        Timer.scheduledTimer(timeInterval: TimeInterval(timeBeforeSegue), target: self, selector: #selector(HTInitViewController.timerComplete), userInfo: nil, repeats: false)
    }
    
    func loadData() {
        DispatchQueue.main.async() {
            let context = getBackgroundContext()
            
            context.perform {
                
                let dataManager = DataImportManager(managedContext: context)
                
                let speakers_file = Bundle.main.path(forResource: "speakers", ofType: "json")!
                let speakers_content = try! String(contentsOfFile: speakers_file)
                let speakers_data = speakers_content.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
                
                do {
                   try dataManager.importSpeakers(speakerData: speakers_data)
                    
                    
                    let message1 = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
                    message1.date = Date()
                    message1.msg = "Welcome to HackerTracker iOS for TOORCON 19. If you have any events, parties, or contests to add, or if you find any errors or typos, email info@beezle.org. Code for this app can be found at https://github.com/BeezleLabs/HackerTracker-iOS."
                    
                    let message2 = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
                    message2.date = Date()
                    message2.msg = "The initial schedule contains official talks, etc. Pull down to update the schedule from official sources."
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
                
                do {
                    try context.save()
                } catch let error as NSError {
                    NSLog("error: \(error)")
                }
            

                self.importComplete = true
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
