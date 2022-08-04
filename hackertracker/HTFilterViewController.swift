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

    var all: [HTTag] = []
    var filtered: [HTTag] = []
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
        centeredConstraint = popupView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        centeredConstraint?.isActive = true

        UIView.animate(withDuration: 0.2) {
            self.view.layoutSubviews()
            self.fadeView.alpha = 0.5
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.all.count
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath)

        let tag = self.all[indexPath.section]
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
            let eventType = self.all[indexPath.section]
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                if let index = filtered.firstIndex(of: eventType) {
                    filtered.remove(at: index)
                }
            } else {
                cell.accessoryType = .checkmark
                filtered.append(eventType)
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
