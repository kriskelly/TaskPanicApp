//
//  TaskListViewController.swift
//  TaskPanic
//
//  Created by Kris Kelly on 3/28/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import UIKit

protocol TaskTableControllerDelegate: class {
    func didSelectTask(task: Task)
}

class TaskListViewController: UIViewController, TaskInputControllerDelegate, TaskTableControllerDelegate {
    var selectedTask: Task?

    var taskService: TaskService?
    weak var tableController: TaskTableViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        for controller in childViewControllers {
            if let tableController = controller as? TaskTableViewController {
                self.tableController = tableController
                tableController.taskService = taskService
                tableController.delegate = self
            }
        }

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(TaskListViewController.openForm))
    }

    func didSaveTaskInput(task: Task) {
        navigationController!.popViewController(animated: true)
        tableController.refreshData()
    }

    func didCancelTaskInput() {
        navigationController!.popViewController(animated: true)
    }

    func didSelectTask(task: Task) {
        self.selectedTask = task
        openForm()
    }

    @objc func openForm() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let taskInputViewController: TaskInputViewController = sb.instantiateViewController(withIdentifier: "TaskInputViewController") as! TaskInputViewController
        taskInputViewController.delegate = self
        taskInputViewController.taskService = taskService
        if let task = selectedTask {
            taskInputViewController.task = task
        }
        navigationController!.pushViewController(taskInputViewController, animated: true)
    }
}
