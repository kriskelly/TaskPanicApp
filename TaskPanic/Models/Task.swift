//
//  Task.swift
//  TaskPanic
//
//  Created by Kris Kelly on 2/28/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import RealmSwift
import EventKit

enum TaskUrgency: Int {
    case Low = 0
    case Medium = 1
    case High = 2
}

enum TaskImportance: Int {
    case Low = 0
    case Medium = 1
    case High = 2
}

class Task: Object {
    @objc dynamic var id = ""
    @objc dynamic var completed = false
    @objc dynamic var completedAt: NSDate? = nil
    @objc dynamic var isFromReminder = false
    @objc dynamic var name = ""
    @objc dynamic var timeLength: Int = 0
    @objc dynamic var calendarEventIdentifier: String = ""
    @objc dynamic var calendarReminderIdentifier: String = ""
    @objc dynamic var dueDate: NSDate? = nil
    @objc dynamic var scheduledAt: NSDate? = nil
    @objc dynamic var importance: Int = TaskImportance.Low.rawValue
    @objc dynamic var urgency: Int = TaskUrgency.Low.rawValue
    
    static func fromReminder(reminder: EKReminder) -> Task {
        let task = Task()
        task.setPrimaryKey()
        task.isFromReminder = true
        task.name = reminder.title
        task.completed = reminder.isCompleted
        task.calendarReminderIdentifier = reminder.calendarItemIdentifier
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        if let dueDateComponents = reminder.dueDateComponents {
            task.dueDate = calendar?.date(from: dueDateComponents) as NSDate?
        }
        return task
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }

    func setPrimaryKey() {
        self.id = NSUUID().uuidString
    }

    func timeLengthInHours() -> Int {
        return timeLength / 60
    }
}
