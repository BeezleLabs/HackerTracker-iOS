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

    let standardLogoHeight = CGFloat(118.0)

    @IBOutlet weak var updatesTableView: UITableView!
    @IBOutlet weak var backgroundImage: UIImageView!

    @IBOutlet weak var logoCenterToTopMargin: NSLayoutConstraint!
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var skullBackground: UIImageView!
    
    @IBOutlet weak var dcIconView: UIImageView!

    var messages: [Article] = []
    var data = NSMutableData()
    
    var footer: UIView!

    var hiddenAnimation: Animation!

    override func viewDidLoad() {
        super.viewDidLoad()
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!

        updatesTableView.rowHeight = UITableViewAutomaticDimension
        updatesTableView.register(UINib.init(nibName: "UpdateCell", bundle: nil), forCellReuseIdentifier: "UpdateCell")
        backgroundImage.image = UIImage.mainHeaderImage(scaledToWidth: self.view.frame.size.width, visibleRect:CGRect(origin: CGPoint.zero, size: CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height * 0.40)))
        
        updatesTableView.delegate = self
        updatesTableView.dataSource = self
        updatesTableView.backgroundColor = UIColor.clear
        updatesTableView.contentInset = UIEdgeInsets(top: view.frame.size.height * 0.4, left: 0, bottom: 0, right: 0)
       
        if let footer = Bundle.main.loadNibNamed("ContributorsFooterView", owner: self, options: nil)?.first as? ContributorsFooterView {
            updatesTableView.tableFooterView = footer
            var frame = updatesTableView.tableFooterView?.frame
            frame?.size.height = view.frame.size.height * 0.25
            updatesTableView.frame = frame ?? CGRect.zero
            updatesTableView.tableFooterView = footer
            footer.footerDelegate = self
            self.footer = footer
        }

        let fr:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Article")
        fr.sortDescriptors = [NSSortDescriptor(key: "updated_at", ascending: false)]
        fr.returnsObjectsAsFaults = false
        self.messages = (try! context.fetch(fr)) as! [Article]

        if hiddenAnimation != nil {
            hiddenAnimation = Animation(duration: 1.0, image: dcIconView.image!) { (image) in
                self.dcIconView.image = image
            }
        }

        if dcIconView != nil {
            dcIconView.layer.zPosition = 100
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.backgroundImage.image = UIImage.mainHeaderImage(scaledToWidth: self.view.frame.size.width, visibleRect:CGRect(origin: CGPoint.zero, size: CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height * 0.40)))

            self.backgroundImage.sizeToFit()
            let topContentInset = min((self.view.frame.size.height * 0.4) - 64, self.backgroundImage.frame.size.height - 64)
            self.updatesTableView.contentInset = UIEdgeInsets(top: topContentInset, left: 0, bottom: 0, right: 0)
            self.scrollViewDidScroll(self.updatesTableView)
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //self.footer.frame.size.height = 360
        updatesTableView.tableFooterView = self.footer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        let fr:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Article")
        fr.sortDescriptors = [NSSortDescriptor(key: "updated_at", ascending: false)]
        fr.returnsObjectsAsFaults = false
        self.messages = (try! context.fetch(fr)) as! [Article]
        
        self.updatesTableView.reloadData()
        let topContentInset = min((self.view.frame.size.height * 0.4) - 64, self.backgroundImage.frame.size.height - 64)
        self.updatesTableView.contentInset = UIEdgeInsets(top: topContentInset, left: 0, bottom: 0, right: 0)        
        scrollViewDidScroll(self.updatesTableView)
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
        if (self.logoHeightConstraint == nil) {
            self.logoHeightConstraint = NSLayoutConstraint.init()
        } else {
            self.logoHeightConstraint.constant = standardLogoHeight - (minHeight * percentage)
        }
        
        //Only make the easter egg visible on top overscroll
        skullBackground.isHidden = scrollView.contentOffset.y > 0
        if logoHeightConstraint != nil {
            logoCenterToTopMargin.constant =  ((updatesTableView.contentInset.top + 64) / 2.0) - ((((updatesTableView.contentInset.top + 64) / 2.0) - 37) * percentage)
        }

        if percentage < -1.37 && !hiddenAnimation.isPlaying {
            hiddenAnimation.startPixelAnimation()
        }

        var perspectiveTransform = CATransform3DIdentity
        perspectiveTransform.m34 = 1.0 / -500.0
        perspectiveTransform = CATransform3DRotate(perspectiveTransform,
                                                   max(.pi / 4 * min(-percentage, 1.0), 0),
                                                   1,
                                                   0,
                                                   0)
    
        UIView.animate(withDuration: 0.1) {
            if self.dcIconView != nil {
                self.dcIconView.layer.transform = perspectiveTransform
            }
        }

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
        }
        
        if let url = url {
            let safariVC = SFSafariViewController(url: url)
            self.present(safariVC, animated: true, completion: nil)
        }

    }
}
