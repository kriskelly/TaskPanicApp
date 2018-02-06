//
//  EventSuggestion.swift
//  TaskPanic
//
//  Created by Kris Kelly on 5/14/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import Foundation
import EventKit

/*!
 
 Display model for event suggestions
 
 */
class SuggestedEvent: NSObject, DisplayableEvent {
    var calendar: EKCalendar? = nil
    var title: String {
        get {
            return taskTimeBlock.task!.name
        }
    }

    var endDate: NSDate {
        get {
            return taskTimeBlock.endDate!
        }
        set(newDate) {
            taskTimeBlock.endDate = newDate
        }
    }
    var startDate: NSDate {
        get {
            return taskTimeBlock.startDate!
        }
        set(newDate) {
            taskTimeBlock.startDate = newDate
        }
    }

    var taskTimeBlock: TaskTimeBlock!

    init(taskTimeBlock: TaskTimeBlock) {
        self.taskTimeBlock = taskTimeBlock
    }
}
