//
//  HTWebViewController.swift
//  hackertracker
//
//  Created by Seth Law on 6/30/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit

class HTWebViewController: UIViewController {

    @IBOutlet weak var wv: UIWebView!
    
    var url:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSLog("Url: \(self.url)")
        if (self.url.rangeOfString("dc-23-speakers.html#") != nil ){
            
            var urlpath = NSBundle.mainBundle().pathForResource("dc-23-speakers", ofType: "html")
            let re = NSRegularExpression(pattern: "#.*$", options: nil, error: nil)
            let nsString = self.url as NSString
            let results = re!.matchesInString(self.url, options: nil, range: NSMakeRange(0,count(self.url)))
            NSLog("result: \(results)")
            wv.loadRequest(NSURLRequest(URL: NSURL(string: "\(urlpath!)" )!))
        }
        //wv.loadRequest(NSURLRequest(URL: NSURL(string: "URL Not Found")),
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeEvent(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
