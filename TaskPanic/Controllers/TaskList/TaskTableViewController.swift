//
//  TaskTableViewController.swift
//  TaskPanic
//
//  Created by Kris Kelly on 3/29/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import UIKit
import RealmSwift

class TaskTableViewController: UITableViewController {
    // MARK: Properties
    var taskService: TaskService?

    weak var delegate: TaskTableControllerDelegate?

    var loadedTasks: Results<Task>?
    var tasksChangedToken: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        refreshData()
    }

    private func taskAtIndex(indexPath: IndexPath) -> Task? {
        return loadedTasks?[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "taskTableCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell?
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
        }
        cell!.textLabel?.text = taskAtIndex(indexPath: indexPath)?.name
        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = taskAtIndex(indexPath: indexPath)
        delegate?.didSelectTask(task: task!)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tasks = loadedTasks {
            return tasks.count
        } else {
            return 0
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func refreshData() {
        self.loadedTasks = taskService!.fetchIncomplete()
        self.tableView.reloadData()
    }

    
}
