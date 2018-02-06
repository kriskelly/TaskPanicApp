//
//  PendingTaskView.swift
//  TaskPanic
//
//  Created by Kris Kelly on 4/12/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import UIKit

class UnscheduledTaskView: UIView {
    var task: Task!

    // MARK - Drag properties
    var longPressGesture: UILongPressGestureRecognizer!

    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    override func didMoveToSuperview() {
        backgroundView.layer.cornerRadius = 15.0
        taskNameLabel.text = task.name
        setupGestures()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setupGestures() {
        self.longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleDrag))
        self.longPressGesture.delegate = self
        self.longPressGesture.minimumPressDuration = 0.3
        backgroundView.addGestureRecognizer(self.longPressGesture)
    }
}

// MARK - Dragging
extension UnscheduledTaskView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    private func collapseOriginalView() {
        heightConstraint.constant = 0
    }

    @objc func handleDrag(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
//            collapseOriginalView()
            notifyOfGesture(eventName: DragNotifications.StartedDragging.rawValue, gesture: gesture)
        } else if gesture.state == .changed {
            notifyOfGesture(eventName: DragNotifications.DragPositionChanged.rawValue, gesture: gesture)

        } else if gesture.state == .ended {
            notifyOfGesture(eventName: DragNotifications.Dropped.rawValue, gesture: gesture)
        }
    }

    func notifyOfGesture(eventName: String, gesture: UILongPressGestureRecognizer) {
        let notifications = NotificationCenter.default
        notifications.post(name: NSNotification.Name(eventName), object: nil, userInfo: [
            DragNotifications.DragGestureKey.rawValue: gesture,
            DragNotifications.TaskKey.rawValue: self.task,
            DragNotifications.ShadowedTaskViewKey.rawValue: self
            ])
    }
}
