//
//  HTCocViewController.swift
//  hackertracker
//
//  Created by Seth W Law on 7/19/19.
//  Copyright © 2019 Beezle Labs. All rights reserved.
//

import UIKit

class HTCocViewController: UIViewController {
    @IBOutlet private var cocTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        var coc = AnonymousSession.shared.currentConference.coc.replacingOccurrences(of: "\\n", with: "\n")

        if coc.isEmpty {
            coc = "Be excellent to each other."
        }

        let titleAttributedString = NSMutableAttributedString(string: coc, attributes: [
            .paragraphStyle: NSParagraphStyle.leftAlignedParagraph,
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.white,
        ])
        self.cocTextView.attributedText = titleAttributedString
    }
}
