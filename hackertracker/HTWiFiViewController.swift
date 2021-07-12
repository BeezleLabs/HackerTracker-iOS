//
//  HTWiFiViewController.swift
//  hackertracker
//
//  Created by Seth Law on 8/4/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import SafariServices
import UIKit

class HTWiFiViewController: UIViewController {
    @IBOutlet private var vertStackView: UIStackView!

    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "#e33a6a")
        view.layer.cornerRadius = 10.0
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.backgroundGray
        pinBackground(backgroundView, to: vertStackView)

       let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))

        self.view.addGestureRecognizer(tapGesture)
    }

    @objc func backgroundTapped() {
        if let url = URL(string: "https://wifireg.defcon.org/") {
            let controller = SFSafariViewController(url: url)
            controller.preferredBarTintColor = UIColor.backgroundGray
            controller.preferredControlTintColor = UIColor.white
            present(controller, animated: true)
        }
    }

    private func pinBackground(_ view: UIView, to stackView: UIStackView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        stackView.insertSubview(view, at: 0)
        view.pin(to: stackView)
    }
}

extension UIView {
    func pin(to view: UIView) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
