//
//  DayPlannerMainViewController+Drag.swift
//  TaskPanic
//
//  Created by Kris Kelly on 6/11/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import UIKit

// MARK - Drag/drop behavior
extension DayPlannerMainViewController {
    func observeDraggedTasks() {
        let notifications = NotificationCenter.default
        notifications.addObserver(forName: NSNotification.Name(rawValue: DragNotifications.StartedDragging.rawValue), object: nil, queue: nil) { (notification) in
            self.onDragStarted(userInfo: notification.userInfo as! [String: AnyObject])
        }
        notifications.addObserver(forName: NSNotification.Name(rawValue: DragNotifications.DragPositionChanged.rawValue), object: nil, queue: nil) { (notification) in
            self.onDragPositionChanged(userInfo: notification.userInfo as! [String: AnyObject])

        }
        notifications.addObserver(forName: NSNotification.Name(rawValue: DragNotifications.Dropped.rawValue), object: nil, queue: nil) { (notification) in
            self.onDragDropped(userInfo: notification.userInfo as! [String: AnyObject])
        }
    }

    private func onDragStarted(userInfo: [String: AnyObject]) {
        self.dragShadowView = createDragShadow(gesture: userInfo[DragNotifications.DragGestureKey.rawValue] as! UILongPressGestureRecognizer,
                                               task: userInfo[DragNotifications.TaskKey.rawValue] as! Task,
                                               shadowedTaskView: userInfo[DragNotifications.ShadowedTaskViewKey.rawValue] as! UnscheduledTaskView)
    }

    private func onDragPositionChanged(userInfo: [String: AnyObject]) {
        let gesture = userInfo[DragNotifications.DragGestureKey.rawValue] as! UILongPressGestureRecognizer
        let shadowedTaskView = userInfo[DragNotifications.ShadowedTaskViewKey.rawValue] as! UnscheduledTaskView
        moveView(dragShadowView: self.dragShadowView, gesture: gesture, shadowedTaskView: shadowedTaskView)
    }

    private func onDragDropped(userInfo: [String: AnyObject]) {
        dragShadowView.removeFromSuperview()
        self.dragShadowView = nil
    }

    private func createDragShadow(gesture: UILongPressGestureRecognizer, task: Task, shadowedTaskView: UnscheduledTaskView) -> CalendarDragShadowView {
        let shadowRect = shadowedTaskView.convert(shadowedTaskView.frame, to: view)
        let dragShadowView = CalendarDragShadowView(task: task, shadowedViewFrame: shadowRect, shadowType: DragShadowType.Unscheduled)
        view.addSubview(dragShadowView)
        saveTouchOffset(gesture: gesture, taskView: shadowedTaskView)
        return dragShadowView
    }

    private func moveView(dragShadowView: CalendarDragShadowView, gesture: UILongPressGestureRecognizer, shadowedTaskView: UnscheduledTaskView) {
        let newY = self.getYPos(gesture: gesture, shadowedTaskView: shadowedTaskView)
        dragShadowView.updateYPos(newY: newY)
        transitionBetweenShadowTypesIfNecessary(gesture: gesture)
        dragShadowView.setNeedsLayout()
    }

    private func getYPos(gesture: UILongPressGestureRecognizer, shadowedTaskView: UnscheduledTaskView) -> CGFloat {
        let gesturePos = gesture.location(in: self.view)
        return gesturePos.y - dragShadowLongPressOffset
    }

    private func saveTouchOffset(gesture: UILongPressGestureRecognizer, taskView: UnscheduledTaskView) {
        let originalGesturePos = gesture.location(in: taskView)
        self.dragShadowLongPressOffset = originalGesturePos.y
    }

    private func setShadowConstraints(dragShadowView: CalendarDragShadowView, gesture: UILongPressGestureRecognizer, shadowedTaskView: UnscheduledTaskView) {
    }

    // Check if the gesture has moved onto the calendar.
    // If so, convert the gesture location to a time on the calendar.
    // If the user then ends the gesture, the drag stopped callback will create the event.
    private func transitionBetweenShadowTypesIfNecessary(gesture: UILongPressGestureRecognizer) {
        let calendarView = calendarViewController.view
        let gestureCalendarPt = gesture.location(in: calendarView)
        // This should be nil if the gesture isn't on the calendar
        if let containerView = calendarView?.hitTest(gestureCalendarPt, with: nil) as? UICollectionView {
            // Transition from unscheduled to calendar
            if dragShadowView.shadowType == DragShadowType.Unscheduled {
                dragShadowView.shadowType = DragShadowType.Scheduled
                dragShadowView.setNeedsLayout()
            }
        } else {
            // Transition from scheduled to unscheduled
            if dragShadowView.shadowType == DragShadowType.Scheduled {
                dragShadowView.shadowType == DragShadowType.Unscheduled
                dragShadowView.setNeedsLayout()
            }
        }
        
    }
}
