//
//  TaskEvent.swift
//  TaskPanic
//
//  Created by Kris Kelly on 5/7/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import Foundation
import EventKit

@objc protocol DisplayableEvent {
    var calendar: EKCalendar? { get }
    var title: String { get }
    var startDate: NSDate { get set }
    var endDate: NSDate { get set }
}

/*!
 Display model for persisted TaskTimeBlock instances.
 
 This munges together a valid calendar event and a persisted
 task time block and makes itself displayable such that the user
 can tell which are real events and which are the accepted
 suggestions the user has made.

 */
class TaskEvent: NSObject, DisplayableEvent {
    let event: EKEvent?
    let taskTimeBlock: TaskTimeBlock

    var calendar: EKCalendar? {
        get {
            return event?.calendar
        }
    }

    var title: String {
        get {
            return taskTimeBlock.task!.name
        }
    }

    var endDate: NSDate
    var startDate: NSDate

    init(taskTimeBlock: TaskTimeBlock, event: EKEvent) {
        self.event = event
        self.endDate = event.endDate as NSDate
        self.startDate = event.startDate as NSDate
        self.taskTimeBlock = taskTimeBlock
    }

    init(taskTimeBlock: TaskTimeBlock) {
        self.event = nil
        self.startDate = taskTimeBlock.startDate!
        self.endDate = taskTimeBlock.endDate!
        self.taskTimeBlock = taskTimeBlock
    }
}
