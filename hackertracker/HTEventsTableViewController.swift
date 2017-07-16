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

struct eventType {
    var name:String
    var img:String
    var dbName:String
    var count:Int
   
    init(n:String,i:String,d:String,c:Int) {
        self.name = n
        self.img = i
        self.dbName = d
        self.count = c
    }
}

class HTEventsScrollingTabController: ScrollingTabController {
    
    var eventTypes: [eventType] = [
        eventType(n: "CONTESTS", i: "contest", d: "Contest", c: 0),
        eventType(n: "EVENTS", i: "calendar-active", d: "Event", c: 0),
        eventType(n: "PARTIES", i: "party", d: "Party", c: 0),
        eventType(n: "KIDS", i: "kids", d: "Kids", c: 0),
        eventType(n: "SKYTALKS", i: "cloud", d: "Skytalks", c: 0),
        eventType(n: "TALKS", i: "speaker", d: "Official", c: 0),
        eventType(n: "VILLAGES", i: "village", d: "Villages", c: 0),
        eventType(n: "WORKSHOPS", i:"workshop", d:"Workshop", c: 0)

    ]
    
    let leftFadedView = UIView()
    let rightFadedView = UIView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
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
        
        tabTheme = CellTheme(font: UIFont(name: "Furore", size: 12)!, defaultColor: UIColor.white.withAlphaComponent(0.75), selectedColor: UIColor.white)
        
        self.viewControllers = eventControllers
        
        leftFadedView.backgroundColor = UIColor.backgroundGray
        rightFadedView.backgroundColor = UIColor.backgroundGray

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        navigationController?.navigationBar.isTranslucent = false
        automaticallyAdjustsScrollViewInsets = true
        
        tabSizing = .fixedSize(110)
        
        tabBarHeight = 40
        tabView.backgroundColor = .backgroundGray
        tabView.centerSelectTabs = true
        tabView.collectionView.reloadData()
        
        selectTab(atIndex: 5, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        selectTab(atIndex: currentPage, animated: false)
    }
}
