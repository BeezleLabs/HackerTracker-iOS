//
//  HTEventsNavViewController.swift
//  hackertracker
//
//  Created by Seth Law on 5/5/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit

class HTEventsNavViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "nav-header"), for: .default)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
