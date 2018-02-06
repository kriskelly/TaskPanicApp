//
//  PendingTasksViewController.swift
//  TaskPanic
//
//  Created by Kris Kelly on 4/12/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import UIKit
import RealmSwift

class PendingTasksViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!

    let TASK_HEIGHT = 30.0

    var tasks: Results<Task>?

    override func viewWillAppear(_ animated: Bool) {
        fixScrollHeight()

        scrollView.delaysContentTouches = false
        loadTaskViews()
    }

    private func fixScrollHeight() {
        if let tasks = tasks {
            let height = TASK_HEIGHT * Double(tasks.count)
            scrollView.contentSize = CGSize(width: Double(view.frame.width), height: height)
            contentViewHeight.constant = CGFloat(height)
        }
    }

    private func loadTaskView(task: Task) {
        let taskNib = Bundle.main.loadNibNamed("UnscheduledTaskView", owner: self, options: nil)
        let taskView = taskNib?.first as! UnscheduledTaskView
        taskView.task = task
        stackView.addArrangedSubview(taskView)
    }

    private func loadTaskViews() {
        (stackView.subviews as [UIView]).map { $0.removeFromSuperview() }
        if let tasks = tasks {
            for task in tasks {
                loadTaskView(task: task)
            }
        }
    }
}
