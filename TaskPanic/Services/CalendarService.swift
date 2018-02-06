//
//  CalendarService.swift
//  TaskPanic
//
//  Created by Kris Kelly on 2/27/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import Foundation
import EventKit

class CalendarService {
    private let eventManager: EventKitManager

    init(eventManager: EventKitManager) {
        self.eventManager = eventManager
    }
    
    func verifyAndLoadCalendarEvents(date: NSDate, completion: @escaping ([CalendarEvent]) -> Void) {
        verifyCalendarAccess { () -> Void in
            let events = self.eventManager.fetchCalendarEvents(forDate: date as Date)
            let wrappedEvents = events.map { CalendarEvent(event: $0) }
            print("Fetched events: \(events.count)")
            completion(wrappedEvents)
        }
    }
    
    func verifyCalendarAccess(completion: @escaping () -> Void) {
        eventManager.checkCalendarAuthorizationStatus(authorized: { () -> Void in
            print("Successfully got calendar access")
            self.eventManager.checkRemindersAuthorizationStatus(authorized: { () -> Void in
                print("Successfully got reminders access")
                completion()
            }, denied: { (status) -> Void in
                print("Denied reminders access")
            })
        }) { (status) -> Void in
            print("Denied calendar access")
        }
    }
}
