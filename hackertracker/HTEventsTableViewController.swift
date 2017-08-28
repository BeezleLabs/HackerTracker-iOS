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
        eventType(n: "CONFERENCE", i: "speaker", d: "Conference", c: 0),
        eventType(n: "WORKSHOPS", i: "workshop", d: "Workshops", c: 0),
        eventType(n: "SEMINARS", i: "seminar", d: "Seminars", c: 0),
        eventType(n: "CONTESTS", i: "party", d: "Contests", c: 0),
        eventType(n: "OTHER", i:"other", d:"Other", c:0)

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
