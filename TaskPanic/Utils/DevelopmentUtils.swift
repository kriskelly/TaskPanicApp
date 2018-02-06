//
//  DevelopmentUtils.swift
//  TaskPanic
//
//  Created by Kris Kelly on 2/28/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import Foundation
import RealmSwift

func purgeRealm() {
    let filePath: URL = Realm.Configuration.defaultConfiguration.fileURL!
    try! FileManager.default.removeItem(atPath: filePath.absoluteString)
}

func useInMemoryRealm() {
    Realm.Configuration.defaultConfiguration = Realm.Configuration(fileURL: Realm.Configuration.defaultConfiguration.fileURL, inMemoryIdentifier: "okiedokie", encryptionKey: nil, readOnly: false, schemaVersion: 1, migrationBlock: nil, deleteRealmIfMigrationNeeded: true, objectTypes: nil)
}

func createStubTasks() {
    let service = TaskService()
    service.createTask(name: "foo", timeLength: 15, dueDate: nil)
    service.createTask(name: "bar", timeLength: 30, dueDate: nil)
    service.createTask(name: "baz", timeLength: 15, dueDate: nil)
}

func createStubTaskEvents() -> [TaskEvent] {
    let task1 = Task()
    task1.name = "Task 1"
    let task2 = Task()
    task2.name = "Task 2"

    let components = NSDateComponents()
    components.hour = 1

    let startDate1 = NSDate()
    let endDate1 = NSCalendar.current.date(byAdding: .hour, value: 1, to: startDate1 as Date)

    let timeBlock1 = TaskTimeBlock()
    timeBlock1.startDate = startDate1
    timeBlock1.endDate = endDate1 as NSDate?
    timeBlock1.task = task1

    let taskEvent = TaskEvent(taskTimeBlock: timeBlock1)

    var taskList: [TaskEvent] = []
    taskList.append(taskEvent)
    return taskList
}
