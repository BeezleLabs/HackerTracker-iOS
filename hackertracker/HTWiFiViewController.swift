//
//  HTWiFiViewController.swift
//  hackertracker
//
//  Created by Seth Law on 8/4/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit
import SafariServices

class HTWiFiViewController: UIViewController {

    @IBOutlet weak var vertStackView: UIStackView!
    
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
        
       let tapGesture = UITapGestureRecognizer(target:self, action: #selector(backgroundTapped))
        
        self.view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func backgroundTapped() {
        
        let l = "https://wifireg.defcon.org/"
        if let u = URL(string: l) {
            let svc = SFSafariViewController(url: u)
            svc.preferredBarTintColor = UIColor.backgroundGray
            svc.preferredControlTintColor = UIColor.white
            present(svc, animated: true, completion: nil)
        }    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func pinBackground(_ view: UIView, to stackView: UIStackView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        stackView.insertSubview(view, at: 0)
        view.pin(to: stackView)
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

public extension UIView {
    public func pin(to view: UIView) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
}
