//
//  TaskService.swift
//  TaskPanic
//
//  Created by Kris Kelly on 2/27/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import Foundation
import RealmSwift

class TaskService {    
    func createTask(name: String, timeLength: Int, dueDate: NSDate?) -> Task? {
        do {
            let realm = try Realm()
            let task = Task()
            task.setPrimaryKey()
            task.name = name
            task.timeLength = timeLength
            task.dueDate = dueDate
            try realm.write({ () -> Void in
                realm.add(task)
            })
            return task
        } catch let error as NSError {
            print("Caught error: \(error)")
        }
        return nil
    }

    func createTask(task: Task) -> Task? {
        do {
            let realm = try Realm()
            task.setPrimaryKey()
            try realm.write({ () -> Void in
                realm.add(task)
            })
            return task
        } catch let error as NSError {
            print("Caught error: \(error)")
        }
        return nil
    }

    func saveTask(task: Task) -> Task? {
        return createTask(task: task)
    }

    func saveTask(task: Task, update: Bool) throws -> Task? {
        if update == true {
            let task = try! updateTask(task: task)
            return task
        } else {
            return createTask(task: task)
        }
    }

    func fetchAll() -> Results<Task>? {
        do {
            let realm = try Realm()
            let results = realm.objects(Task.self)
            return results
        } catch let error as NSError {
            print("Caught error: \(error)")
        }
        return nil
    }
    
    // TODO: Actually fetch only incomplete tasks here.
    func fetchIncomplete() -> Results<Task>? {
        do {
            let realm = try Realm()
            let results = realm.objects(Task.self).filter("completed = false")
            return results
        } catch let error as NSError {
            print("Caught error: \(error)")
        }
        return nil
    }

    func fetchIncompleteUnscheduledTasks() -> Results<Task>? {
        do {
            let realm = try Realm()
            let results = realm.objects(Task.self).filter("scheduledAt = nil AND completed = false")
            return results
        } catch let error as NSError {
            print("Caught error: \(error)")
        }
        return nil
    }
    
    func updateAll(tasks: [Task]) {
        do {
            let realm = try Realm()
            try realm.write({ () -> Void in
                for task in tasks {
                  realm.add(task, update: true)
                }
            })
        } catch let error as NSError {
            print("Caught error: \(error)")
        }
    }

    private func updateTask(task: Task) throws -> Task? {
        let realm = try Realm()
        try realm.write({ () -> Void in
            realm.add(task, update: true)
        })
        return task
    }
}
