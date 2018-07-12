//
//  ScrollingTabController.swift
//  hackertracker
//
//  Created by Seth Law on 6/27/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData
import WillowTreeScrollingTabController

class HTEventsScrollingTabController: ScrollingTabController {
    
    var eventTypes: [EventType] = []
    
    
    var leftFadedView: UIView!
    var rightFadedView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        for con in DataRequestManager(managedContext: context).getSelectedConferences() {
            for et in (con.event_types?.allObjects as! [EventType]).sorted(by: {$0.name! < $1.name! }) {
                eventTypes.append(et)
            }
        }
        
        leftFadedView = UIView()
        rightFadedView = UIView()
        numToPreload = eventTypes.count + 2
        
        var eventControllers = [HTScheduleTableViewController]()
        
        for eventType in eventTypes
        {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let schedule = storyboard.instantiateViewController(withIdentifier: "ScheduleTableViewController") as! HTScheduleTableViewController
            schedule.eType = eventType;
            schedule.tabBarItem.title = eventType.name
            eventControllers.append(schedule)
        }

        tabView.selectionIndicator.tintColor = UIColor.white.withAlphaComponent(0.75)
        tabView.selectionIndicator.backgroundColor = UIColor.white.withAlphaComponent(0.75)

        tabView.selectionIndicator.tintColor = UIColor.white.withAlphaComponent(0.75)
        
        tabTheme = CellTheme(font: UIFont(name: "Bungee", size: 12)!, defaultColor: UIColor.white.withAlphaComponent(0.75), selectedColor: UIColor.white)
        
        self.viewControllers = eventControllers
        
        leftFadedView.backgroundColor = UIColor.backgroundGray
        rightFadedView.backgroundColor = UIColor.backgroundGray

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.backgroundGray
        navigationController?.navigationBar.isTranslucent = false
        automaticallyAdjustsScrollViewInsets = true
        
        tabSizing = .fixedSize(110)
        
        tabBarHeight = 40
        tabView.backgroundColor = .backgroundGray
        tabView.centerSelectTabs = true
        tabView.collectionView.reloadData()
        
        selectTab(atIndex: 0, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        selectTab(atIndex: currentPage, animated: false)
    }
}
