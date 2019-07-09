//
//  HTSpeakersTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 8/6/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData
import Crashlytics

class HTSpeakersTableViewController: UITableViewController {
    
    typealias SpeakerSection = (letter: String, speakers: [Speaker])
    
    var speakerSections : [SpeakerSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        reloadSpeakers()
        tableView.scrollToNearestSelectedRow(at: UITableView.ScrollPosition.middle, animated: false)
        self.clearsSelectionOnViewWillAppear = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return speakerSections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return speakerSections[section].speakers.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dateHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "EventHeader") as? EventDateHeaderView ?? EventDateHeaderView(reuseIdentifier: "EventHeader")
        
        dateHeader.bind(speakerSections[section].letter)
        
        return dateHeader
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var ret: [String] = []
        for ss in speakerSections {
            if ss.speakers.count > 0 {
                ret.append(ss.letter)
            }
        }
        return ret
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "speakerCell", for: indexPath)

        if let n = self.speakerSections[indexPath.section].speakers[indexPath.row].name {
            cell.textLabel?.text = n
        }

        return cell
    }
    
    func reloadSpeakers () {
        let selectedIndexPath = tableView.indexPathForSelectedRow
        var speaker: Speaker?
        
        if let selectedIndexPath = selectedIndexPath {
            speaker = speakerSections[selectedIndexPath.section].speakers[selectedIndexPath.row]
        }
        
        speakerSections.removeAll()
        
        for l in "abcdefghijklmnopqrstuvwxyz" {
            let sortedSpeakers = getSpeakers(String(l))
            if sortedSpeakers.count > 0 {
                speakerSections.append((letter: String(l).uppercased(), speakers: sortedSpeakers))
            }
        }
        
        tableView.reloadData()
        
        if let selectedIndexPath = selectedIndexPath,
            let speaker = speaker,
            selectedIndexPath.section < speakerSections.count,
            selectedIndexPath.row < speakerSections[selectedIndexPath.section].speakers.count {
            
            let newSpeaker = speakerSections[selectedIndexPath.section].speakers[selectedIndexPath.row]
            if newSpeaker == speaker {
                tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
            }
        }
    }
    
    func getSpeakers(_ forLetter: String) -> [Speaker] {
        let context = getContext()
        if let conference = DataRequestManager(managedContext: context).getSelectedConference() {
            let fr = NSFetchRequest<NSFetchRequestResult>(entityName:"Speaker")
            fr.predicate = NSPredicate(format: "conference = %@ AND name beginswith[lc] %@", argumentArray: [conference, forLetter])
            
            fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            fr.returnsObjectsAsFaults = false
            let ret = try! context.fetch(fr) as! [Speaker]
            return ret
        } else {
            return []
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "speakerSegue") {
            let svc: HTSpeakerViewController
            
            if let destNav = segue.destination as? UINavigationController, let _svc = destNav.viewControllers.first as? HTSpeakerViewController {
                svc = _svc
            } else {
                svc = segue.destination as! HTSpeakerViewController
            }
            
            var ip : IndexPath
            if let sc = sender as? UITableViewCell {
                ip = tableView.indexPath(for: sc)! as IndexPath
            } else {
                ip = sender as! IndexPath
            }
            
            svc.speaker = self.speakerSections[ip.section].speakers[ip.row]
            
        }
    }
    

}
