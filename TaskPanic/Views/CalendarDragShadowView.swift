//
//  CalendarDragShadowView.swift
//  TaskPanic
//
//  Created by Kris Kelly on 5/2/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import UIKit
import CalendarLib
import SnapKit

enum DragShadowType {
    case Unscheduled
    case Scheduled
}

class CalendarDragShadowView: UIView {
    var dragShadowTopConstraint: Constraint? = nil
    private var previousShadowType: DragShadowType?
    private var shadowedViewFrame: CGRect!
    private var _shadowType: DragShadowType?
    var shadowType: DragShadowType! {
        get {
            return _shadowType
        }
        set {
            self.previousShadowType = _shadowType
            self._shadowType = newValue
        }
    }
    var task: Task!

    convenience init(task: Task, shadowedViewFrame: CGRect, shadowType: DragShadowType) {
        self.init()
        self.shadowedViewFrame = shadowedViewFrame
        self.shadowType = shadowType
        self.task = task
    }

    override func layoutSubviews() {
        if shadowType == .Unscheduled && previousShadowType != .Unscheduled {
            displayAsUnscheduledTask()
        } else if shadowType == .Scheduled && previousShadowType != .Scheduled {
            displayAsCalendarEvent()
        }
    }

    func updateYPos(newY: CGFloat) {
        self.dragShadowTopConstraint?.updateOffset(amount: newY)
    }

    private func displayAsCalendarEvent() {
        let eventView = MGCStandardEventView()
        eventView.title = task.name
        eventView.color = UIColor.blue
        addSubview(eventView)
        eventView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        previousShadowType = .Scheduled
    }

    private func displayAsUnscheduledTask() {
        let taskNib = Bundle.main.loadNibNamed("UnscheduledTaskView", owner: self, options: nil)
        let taskView = taskNib?.first as! UnscheduledTaskView
        taskView.task = task
        addSubview(taskView)
        taskView.snp_makeConstraints({ (make) in
            make.left.equalTo(shadowedViewFrame.origin.x)
            make.right.equalTo(shadowedViewFrame.origin.x + shadowedViewFrame.size.width)
            self.dragShadowTopConstraint = make.top.equalTo(shadowedViewFrame.origin.y).constraint
        })
        previousShadowType = .Unscheduled
    }
}
