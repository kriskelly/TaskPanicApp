//
//  TaskTimeBlock.swift
//  TaskPanic
//
//  Created by Kris Kelly on 5/8/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import Foundation
import RealmSwift

class TaskTimeBlock: Object {
    @objc dynamic var startDate: NSDate? = nil
    @objc dynamic var endDate: NSDate? = nil
    @objc dynamic var task: Task?
}
