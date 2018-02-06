//
//  EventKitManager.swift
//  TaskPanic
//
//  Created by Kris Kelly on 3/13/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import Foundation
import EventKit

class EventKitManager {
    private let eventStore: EKEventStore

    var defaultCalendar: EKCalendar {
        get {
            return eventStore.defaultCalendarForNewEvents!
        }
    }

    init() {
        eventStore = EKEventStore()
    }
    
    func checkAuthForEKEntity(entityType: EKEntityType, authorized: @escaping () -> Void,
        denied: @escaping (EKAuthorizationStatus) -> Void) {
        let status = EKEventStore.authorizationStatus(for: entityType)
        
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            // This happens on first-run
            requestAccessForEKEntity(entityType: entityType, authorized: authorized, denied: denied)
        case EKAuthorizationStatus.authorized:
            DispatchQueue.main.async (execute: {
                authorized()
            })
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            DispatchQueue.main.async(execute: {
                denied(status)
            })
        }
    }
    
    func requestAccessForEKEntity(entityType: EKEntityType, authorized: @escaping () -> Void,
        denied: @escaping (EKAuthorizationStatus) -> Void) {
            eventStore.requestAccess(to: entityType, completion: {
                (accessGranted, error) in
                
                if accessGranted == true {
                    DispatchQueue.main.async(execute: {
                        authorized()
                    })
                } else {
                    DispatchQueue.main.async(execute: {
                        denied(EKAuthorizationStatus.denied)
                    })
                }
            })
    }
    
    func checkCalendarAuthorizationStatus(authorized: @escaping () -> Void,
        denied: @escaping (_ status: EKAuthorizationStatus) -> Void) {
            checkAuthForEKEntity(entityType: EKEntityType.event, authorized: authorized, denied: denied)
    }
    
    func checkRemindersAuthorizationStatus(authorized: @escaping () -> Void,
        denied: @escaping (EKAuthorizationStatus) -> Void) {
            checkAuthForEKEntity(entityType: EKEntityType.reminder, authorized: authorized, denied: denied)
    }
    
    func fetchCalendarEvents(forDate date: Date) -> [EKEvent] {
        let defaultCalendar = eventStore.defaultCalendarForNewEvents
        let predicate = eventStore.predicateForEvents(withStart: date.startOfDay() as Date, end: date.endOfDay() as Date, calendars: [defaultCalendar!])
        return eventStore.events(matching: predicate)
    }
    
    func fetchAllIncompleteReminders(completion: @escaping ([EKReminder]) -> Void) {
        let defaultCalendar = eventStore.defaultCalendarForNewReminders()
        let predicate = eventStore.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: [defaultCalendar!])
        eventStore.fetchReminders(matching: predicate, completion: { (reminders: [EKReminder]?) -> Void in
            completion(reminders!)
        })
    }

    func newEvent() -> EKEvent {
        let event = EKEvent(eventStore: eventStore)
        return event
    }

    func updateReminders(reminders: [EKReminder]) {
        do {
            for reminder in reminders {
                try eventStore.save(reminder, commit: false)
            }
            try eventStore.commit()
        } catch let error as NSError {
            print("Error when saving reminders: \(error)")
        }
    }
}
