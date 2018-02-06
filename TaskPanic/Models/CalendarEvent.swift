//
//  CalendarEvent.swift
//  TaskPanic
//
//  Created by Kris Kelly on 5/7/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import Foundation
import EventKit

// Wrapper around EKEvent that implements a common protocol
// with TaskEvents.

class CalendarEvent: NSObject, DisplayableEvent {
    let event: EKEvent
    var endDate: NSDate
    var startDate: NSDate

    var calendar: EKCalendar? {
        get {
            return event.calendar
        }
    }

    var title: String {
        get {
            return event.title
        }
    }

    init(event: EKEvent) {
        self.event = event
        self.endDate = event.endDate as NSDate
        self.startDate = event.startDate as NSDate
    }
}
