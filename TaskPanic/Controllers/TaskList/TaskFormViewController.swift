//
//  TaskFormViewController.swift
//  TaskPanic
//
//  Created by Kris Kelly on 5/3/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import UIKit
import Eureka

enum TaskFormFieldNames: String {
    case Name = "Task Name"
    case TimeLength = "Time Length"
    case DueDate = "Due Date"
    case Urgency = "Urgency"
    case Importance = "Importance"
}

class TaskFormViewController: FormViewController {
    var task: Task?

    let timeLengthOptions: [Int] = [1, 2, 5, 10, 40, 80]

    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section()
            <<< TextRow(TaskFormFieldNames.Name.rawValue) {
                $0.title = "Task Name"
                if let task = task {
                    $0.value = task.name
                }

            }
            <<< PickerInlineRow<Int>(TaskFormFieldNames.TimeLength.rawValue) { [weak self] (row : PickerInlineRow<Int>) -> Void in
                guard let s = self else { return }
                row.title = "Estimated Time (in hours)"
                row.options = []
                row.displayValueFor = { (opt) in
                    // Display as hours
                    if let opt = opt {
                        return String(opt)
                    }
                    return ""
                }
                if let task = s.task {
                    row.value = task.timeLengthInHours()
                } else {
                    row.value = s.timeLengthOptions[0]
                }

                let timeOptions = s.timeLengthOptions
                for opt in timeOptions {
                    row.options.append(opt)
                }

            }
            <<< DateInlineRow(TaskFormFieldNames.DueDate.rawValue) {
                $0.title = "Due Date"
                $0.value = nil
            }
            +++ Section("Priority (relative to other tasks)")
            <<< SegmentedRow<Int>(TaskFormFieldNames.Urgency.rawValue) {
                $0.displayValueFor = { (option) in
                    if let option = option {
                        switch(option) {
                        case TaskUrgency.Low.rawValue: return "!"
                        case TaskUrgency.Medium.rawValue: return "!!"
                        case TaskUrgency.High.rawValue: return "!!!"
                        default: return nil
                        }
                    }
                    return nil
                }
                $0.title = "Urgency"
                if let task = task {
                    $0.value = task.urgency
                } else {
                    $0.value = TaskUrgency.Low.rawValue
                }

                $0.options = [
                    TaskUrgency.Low.rawValue,
                    TaskUrgency.Medium.rawValue,
                    TaskUrgency.High.rawValue
                ]
                
            }
            <<< SegmentedRow<Int>(TaskFormFieldNames.Importance.rawValue) {
                $0.title = "Importance"

                $0.displayValueFor = { (option) in
                    if let option = option {
                        switch(option) {
                        case TaskUrgency.Low.rawValue: return "!"
                        case TaskUrgency.Medium.rawValue: return "!!"
                        case TaskUrgency.High.rawValue: return "!!!"
                        default: return nil
                        }
                    }
                    return nil
                }

                if let task = task {
                    $0.value = task.importance
                } else {
                    $0.value = TaskUrgency.Low.rawValue
                }

                $0.options = [
                    TaskImportance.Low.rawValue,
                    TaskImportance.Medium.rawValue,
                    TaskImportance.High.rawValue
                ]
        }
    }
}
