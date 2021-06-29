//
//  HTCocViewController.swift
//  hackertracker
//
//  Created by Seth W Law on 7/19/19.
//  Copyright © 2019 Beezle Labs. All rights reserved.
//

import UIKit

class HTCocViewController: UIViewController {

    @IBOutlet weak var cocTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        var coc = AnonymousSession.shared.currentConference.coc.replacingOccurrences(of: "\\n", with: "\n")

        if coc == "" {
            coc = "Be excellent to each other."
        }
        let titleAttributedString = NSMutableAttributedString(string: coc)
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = .left
        titleAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: titleParagraphStyle, range: NSRange(location: 0, length: (coc as NSString).length))
        titleAttributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.preferredFont(forTextStyle: .body), range: NSRange(location: 0, length: (coc as NSString).length))
        titleAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: (coc as NSString).length))

        self.cocTextView.attributedText = titleAttributedString

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
