//
//  TaskInputViewController.swift
//  TaskPanic
//
//  Created by Kris Kelly on 3/29/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import UIKit

protocol TaskInputControllerDelegate {
    func didCancelTaskInput()
    func didSaveTaskInput(task: Task)
}

class TaskInputViewController: UIViewController {
    var delegate: TaskInputControllerDelegate?
    var formController: TaskFormViewController!
    var task: Task?
    var taskService: TaskService?

    // Default 15 minutes
    var timeLength: Int8 = 15

    override func viewDidLoad() {
        super.viewDidLoad()
        setupForm()
        setupNavButtons()
    }

    @objc func cancelTapped() {
        delegate?.didCancelTaskInput()
    }

    private func getFormValues() -> [String: Any?] {
        return formController.form.values()
    }


    @objc func saveTapped() {
        let formValues = getFormValues()
        let mapper = TaskFormMapper()
        // Because of how Realm works, we need to create a new Task here
        // instead of updating the old one.
        let newTask = mapper.map(fromFormValues: formValues)
        if let task = task {
            newTask.id = task.id
            do {
                try taskService!.saveTask(task: newTask, update: true)
                self.delegate?.didSaveTaskInput(task: newTask)
            } catch let error as NSError {
                print("ERROR: There was an error updating the task: \(error)")
            }
        } else {
            // FIXME: Reconcile service behavior between creating / updating (both should throw)
            if taskService!.saveTask(task: newTask) != nil {
                self.delegate?.didSaveTaskInput(task: newTask)
            }
        }
    }

    func setupForm() {
        self.formController = TaskFormViewController()
        if let task = task {
            formController.task = task
        }
        addChildViewController(formController)
        view.addSubview(formController.view)
        formController.view.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(view)
        }
    }

    func setupNavButtons() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(self.saveTapped))

        let backButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelTapped))

        navigationItem.leftBarButtonItem = backButton
    }
}

