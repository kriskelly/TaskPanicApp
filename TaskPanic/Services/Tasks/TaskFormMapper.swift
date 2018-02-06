//
//  TaskFormMapper.swift
//  TaskPanic
//
//  Created by Kris Kelly on 5/3/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import Foundation

class TaskFormMapper {
    func map(fromFormValues formValues:[String:Any?]) -> Task {
        // Always need to create a new Task object bc of how Realm works.
        let task = Task()
        task.name = formValues[TaskFormFieldNames.Name.rawValue] as! String
        // Time length currently stored as minutes
        if let timeLength = formValues[TaskFormFieldNames.TimeLength.rawValue] as? Int {
            task.timeLength = timeLength * 60
        }

        task.dueDate = formValues[TaskFormFieldNames.DueDate.rawValue] as? NSDate
        task.urgency = formValues[TaskFormFieldNames.Urgency.rawValue] as! Int

        task.importance = formValues[TaskFormFieldNames.Importance.rawValue] as! Int
        return task
    }
}
