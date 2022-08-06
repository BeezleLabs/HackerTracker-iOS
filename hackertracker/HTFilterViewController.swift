//
//  HTFilterViewController.swift
//  hackertracker
//
//  Created by Seth Law on 7/15/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit

class HTFilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet private var popupView: UIView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var bottomToTop: NSLayoutConstraint!
    @IBOutlet private var fadeView: UIView!
    @IBOutlet private var toggleButton: UIButton!
    @IBOutlet private var popupViewHeight: NSLayoutConstraint!
    
    typealias FilterSections = (name: String, tags: [HTTag])

    var all: [HTTag] = []
    var filtered: [HTTag] = []
    var sections: [FilterSections] = []
    weak var delegate: FilterViewControllerDelegate?
    var toggle = true

    var centeredConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(close))
        fadeView.addGestureRecognizer(tapGesture)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bottomToTop.isActive = false
        popupViewHeight.constant = self.view.frame.height - 200
        centeredConstraint = popupView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        centeredConstraint?.isActive = true

        UIView.animate(withDuration: 0.2) {
            self.view.layoutSubviews()
            self.fadeView.alpha = 0.5
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].tags.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2.0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 40
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let filterHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FilterHeader") as? FilterHeaderView ?? FilterHeaderView(reuseIdentifier: "FilterHeader")

        filterHeader.bind(sections[section].name)

        return filterHeader
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath)

        NSLog("Schedule: checking filter section \(indexPath.section) and row \(indexPath.row)")
        let tag = self.sections[indexPath.section].tags[indexPath.row]
        cell.textLabel?.text = tag.label

        if filtered.contains(tag) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let tag = self.sections[indexPath.section].tags[indexPath.row]
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                if let index = filtered.firstIndex(of: tag) {
                    filtered.remove(at: index)
                }
            } else {
                cell.accessoryType = .checkmark
                filtered.append(tag)
            }
            delegate?.filterList(filteredTags: filtered)
        }
    }

    @IBAction private func toggleCheck(_ sender: Any) {
        if toggle {
            filtered = []
        } else {
            filtered = all
        }
        toggle.toggle()
        self.tableView.reloadData()
        delegate?.filterList(filteredTags: filtered)
    }

    @IBAction private func doneButtonPressed(_ sender: Any) {
        close()
    }

    @objc func close() {
        delegate?.filterList(filteredTags: filtered)

        if let centeredConstraint = centeredConstraint {
            centeredConstraint.isActive = false
            popupView.topAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

            UIView.animate(withDuration: 0.4, animations: {
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.dismiss(animated: false)
            })
        } else {
            dismiss(animated: true)
        }
    }
}

protocol FilterViewControllerDelegate: AnyObject {
    func filterList(filteredTags: [HTTag])
}
