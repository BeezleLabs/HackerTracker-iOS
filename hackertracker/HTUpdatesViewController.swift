//
//  HTUpdatesViewController.swift
//  hackertracker
//
//  Created by Seth Law on 3/30/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData
import SafariServices

class HTUpdatesViewController: UIViewController {
    
    @IBOutlet weak var updatesTableView: UITableView!
    
    @IBOutlet weak var headerImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundImage: UIImageView!
    var messages: [Message] = []
    var data = NSMutableData()
    var syncAlert = UIAlertController(title: nil, message: "Syncing...", preferredStyle: .alert)
    
    var footer = UIView()
    
    @IBOutlet weak var logoCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var leadingImageConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var trailingImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var skullBackground: UIImageView!
    
    let footerView = ContributorsFooterView()
    
    let standardLogoHeight = CGFloat(118.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        updatesTableView.register(UINib.init(nibName: "UpdateCell", bundle: nil), forCellReuseIdentifier: "UpdateCell")
        
        updatesTableView.delegate = self
        updatesTableView.dataSource = self
        updatesTableView.backgroundColor = UIColor.clear
        updatesTableView.contentInset = UIEdgeInsets(top: 296, left: 0, bottom: 0, right: 0)
        if let footer = Bundle.main.loadNibNamed("ContributorsFooterView", owner: self, options: nil)?.first as? ContributorsFooterView {
            updatesTableView.tableFooterView = footer
            var frame = updatesTableView.tableFooterView?.frame
            frame?.size.height = 360
            updatesTableView.frame = frame ?? CGRect.zero
            updatesTableView.tableFooterView = footer
            footer.footerDelegate = self
            self.footer = footer
        }
        

        let fr:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Message")
        fr.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        fr.returnsObjectsAsFaults = false
        self.messages = (try! context.fetch(fr)) as! [Message]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.footer.frame.size.height = 360
        updatesTableView.tableFooterView = self.footer

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updatesTableView.contentInset = UIEdgeInsets(top: backgroundImage.frame.size.height - 64, left: 0, bottom: 0, right: 0)
    }
    
}

extension HTUpdatesViewController : UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell") as! UpdateCell
        
        cell.bind(message: messages[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let minHeight = standardLogoHeight - 40
        let percentage = min(1.0 + (scrollView.contentOffset.y / scrollView.contentInset.top), 1.0)
        self.logoHeightConstraint.constant = standardLogoHeight - (minHeight * percentage)
        self.logoCenterYConstraint.constant = -((self.backgroundImage.frame.height / 2) - 38) * percentage
        
        //Only make the easter egg visible on top overscroll
        skullBackground.isHidden = scrollView.contentOffset.y > 0
    }
}

extension HTUpdatesViewController : ContributorsFooterDelegate {
    func linkTapped(link: LinkType) {
        var url : URL? = nil
        switch link {
        case .chrismays94:
            url = URL(string: "https://twitter.com/chrismays94")!
        case .imachumphries:
            url = URL(string: "https://twitter.com/imachumphries")!
        case .macerameg:
            url = URL(string: "https://twitter.com/macerameg")!
            break
        case .sethlaw:
            url = URL(string: "https://twitter.com/sethlaw")!
            break
        case .willowtree:
            let bundleIdentifier = "org.beezle.hackertracker"
            let platform = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone ? "iphone" : "ipad"
            let urlPath = "http://www.willowtreeapps.com/?utm_source=\(bundleIdentifier)&utm_medium=\(platform)&utm_campaign=attribution"
            
            if let unwrappedUrl = URL(string: urlPath) {
                url = unwrappedUrl

            }
            
            break
        }
        
        if let url = url {
            let safariVC = SFSafariViewController(url: url)
            self.present(safariVC, animated: true, completion: nil)
        }

    }
}
