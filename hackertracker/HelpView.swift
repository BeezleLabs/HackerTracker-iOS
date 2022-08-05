//  swiftlint:disable:this file_name
//  HelpView.swift
//  hackertracker
//
//  Created by Seth W Law on 8/2/22.
//  Copyright © 2022 Beezle Labs. All rights reserved.
//

import UIKit

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

class HelpUIView: UIViewController {
    @IBOutlet private var helpLabel: UILabel!
    @IBOutlet private var helpTextView: UITextView!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var helpText = "404 not found"
        if !AnonymousSession.shared.currentConference.supportDoc.isEmpty {
            helpText = AnonymousSession.shared.currentConference.supportDoc
            helpTextView.text = helpText.htmlToString
        }
        helpLabel.layer.masksToBounds = true
        helpLabel.layer.cornerRadius = 5
        helpTextView.layer.masksToBounds = true
        helpTextView.layer.cornerRadius = 5
        self.view.backgroundColor = UIColor.black
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
