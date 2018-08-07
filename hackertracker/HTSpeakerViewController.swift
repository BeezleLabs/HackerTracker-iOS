//
//  HTSpeakerViewController.swift
//  hackertracker
//
//  Created by Seth Law on 8/6/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit
import SafariServices

class HTSpeakerViewController: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var talkButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var vertStackView: UIStackView!
    
    var speaker: Speaker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let s = speaker, let n = s.name, let d = s.desc {
            nameLabel.text = n
            bioLabel.text = d
            if let events = speaker?.events?.allObjects {
                if let e = events[0] as? Event {
                    talkButton.titleLabel?.numberOfLines = 3
                    talkButton.titleLabel?.lineBreakMode = .byWordWrapping
                    talkButton.setTitle(e.title, for: UIControlState.normal)
                }
            }
            twitterButton.isHidden = true
            if let t = s.twitter {
                if t != "" {
                    twitterButton.setTitle(t, for: .normal)
                    twitterButton.isHidden = false
                }
            }
            vertStackView.layoutSubviews()
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func twitterTapped(_ sender: Any) {
        if let twit = speaker?.twitter {
            let l = "https://mobile.twitter.com/\(twit.replacingOccurrences(of: "@", with: ""))"
            if let u = URL(string: l) {
                let svc = SFSafariViewController(url: u)
                svc.preferredBarTintColor = UIColor.backgroundGray
                svc.preferredControlTintColor = UIColor.white
                present(svc, animated: true, completion: nil)
            }
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "eventSegue") {
            
            let dv : HTEventDetailViewController
            
            if let destinationNav = segue.destination as? UINavigationController, let _dv = destinationNav.viewControllers.first as? HTEventDetailViewController {
                dv = _dv
            } else {
                dv = segue.destination as! HTEventDetailViewController
            }
            
            if let events = speaker?.events?.allObjects {
                if let e = events[0] as? Event {
                    dv.event = e
                }
            }
            dv.transitioningDelegate = self
            
        }
    }

}
