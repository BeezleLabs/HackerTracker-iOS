//
//  HTFAQTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 7/12/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit

class HTFAQTableViewController: UITableViewController {
    var faqsToken: UpdateToken?
    var faqs: [HTFAQModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadFAQs()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return faqs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "faqCell", for: indexPath)

        cell.textLabel?.text = self.faqs[indexPath.row].question

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let body = """
        Q: \(faqs[indexPath.row].question)

        A: \(faqs[indexPath.row].answer)
        """

        let messageText = NSMutableAttributedString(
            string: body,
            attributes: [
                .paragraphStyle: NSParagraphStyle.leftAlignedParagraph,
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: UIColor.black,
            ]
        )

        let popup = UIAlertController(title: "FAQ", message: "", preferredStyle: UIAlertController.Style.alert)
        popup.setValue(messageText, forKey: "attributedMessage")

        let doneItem = UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil)
        popup.addAction(doneItem)

        self.present(popup, animated: true)
    }

    func alertControllerBackgroundTapped() {
        self.dismiss(animated: true)
    }

    func loadFAQs() {
        faqsToken = FSConferenceDataController.shared.requestFAQs(forConference: AnonymousSession.shared.currentConference, descending: false) { result in
            switch result {
            case .success(let faqsList):
                self.faqs = faqsList
                self.tableView.reloadData()
            case .failure:
                // TODO: Properly log failure
                break
            }
        }
    }
}
