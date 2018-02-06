//
//  LocalSyncService.swift
//  TaskPanic
//
//  Created by Kris Kelly on 3/13/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import Foundation
import EventKit
import RealmSwift

class LocalSyncService {
    private let eventManager: EventKitManager
    private let taskService: TaskService
    
    init(eventManager: EventKitManager, taskService: TaskService) {
        self.eventManager = eventManager
        self.taskService = taskService
    }
    
    func syncTasksWithReminders() {
        // Fetch reminders
        // Fetch all tasks
        eventManager.fetchAllIncompleteReminders { [unowned self] (reminders: [EKReminder]) -> Void in
            if let tasks = self.taskService.fetchAll() {
                self.doTaskReminderSync(tasks: tasks, reminders: reminders)
            }
        }
    }
    
    private func doTaskReminderSync(tasks: Results<Task>, reminders: [EKReminder]) {
        // Determine whether any reminders match existing tasks
        // For those reminders that don't match an existing task,
        //   create a new task
        // For those tasks that correspond to completed reminders,
        //   mark the tasks as done
        // For those completed tasks that correspond to incomplete reminders,
        //   mark the reminders as completed
        let taskTable = tasks.reduce([String:Task](), { (dict, task: Task) -> [String:Task] in
            var dict = dict
            dict[task.calendarReminderIdentifier] = task
            return dict
        })
        
        var tasksToUpdate = [Task]()
        var remindersToUpdate = [EKReminder]()
        
        for reminder in reminders {
            // Reminder corresponds to a task
            if let task = taskTable[reminder.calendarItemIdentifier] {
                if reminder.isCompleted && !task.completed {
                    task.completed = true
                    tasksToUpdate.append(task)
                } else if (task.completed && !reminder.isCompleted) {
                    reminder.isCompleted = true
                    remindersToUpdate.append(reminder)
                }
            } else {
                // Create a task for this
                let task = Task.fromReminder(reminder: reminder)
                tasksToUpdate.append(task)
                print("New task from reminder: \(task.name)")
            }
        }
        
        taskService.updateAll(tasks: tasksToUpdate)
        eventManager.updateReminders(reminders: remindersToUpdate)
    }
}
