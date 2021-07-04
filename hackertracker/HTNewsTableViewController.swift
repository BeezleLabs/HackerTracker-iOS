//
//  HTNewsTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 7/19/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import CoreData
import UIKit

class HTNewsTableViewController: UITableViewController {
    var articles: [HTArticleModel] = []
    var articlesToken: UpdateToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.register(UINib(nibName: "UpdateCell", bundle: nil), forCellReuseIdentifier: "UpdateCell")

        self.loadArticles()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell", for: indexPath) as! UpdateCell
        cell.bind(message: articles[indexPath.row])
        return cell
    }

    func loadArticles() {
        articlesToken = FSConferenceDataController.shared.requestArticles(forConference: AnonymousSession.shared.currentConference, descending: true) { result in
            switch result {
            case .success(let articlesList):
                self.articles = articlesList
                self.tableView.reloadData()
            case .failure:
                // TODO: Properly log failure
                break
            }
        }
    }
}
