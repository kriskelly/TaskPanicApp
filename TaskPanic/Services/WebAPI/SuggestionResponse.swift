//
//  SuggestionResponse.swift
//  TaskPanic
//
//  Created by Kris Kelly on 5/14/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct SuggestionResponse {
    let apiResponse: DataResponse<AnyObject>
    let dateFormatter: DateFormatter!

    var suggestedEvents: [SuggestedEvent] {
        get {
            guard let rawJSON = apiResponse.result.value else { return [] }
            let wrappedJSON = JSON(rawJSON)
            return wrappedJSON.map({ (key, obj) -> SuggestedEvent in
                return suggestedEventFromJSON(json: obj)
            })
        }
    }

    init(apiResponse: DataResponse<AnyObject>) {
        self.apiResponse = apiResponse
        self.dateFormatter = DateFormatter()
        dateFormatter.setDateFormatToUTC()
        dateFormatter.locale = .current
    }

    func suggestedEventFromJSON(json: JSON) -> SuggestedEvent {
        let taskJSON = json["task"]
        let task = Task()
        if let name = taskJSON["name"].string {
            task.name = name
        }
        if let id = taskJSON["id"].string {
            task.id = id
        }
        let taskTimeBlock = TaskTimeBlock()
        taskTimeBlock.task = task
        if let startDate = json["startDate"].double {
            taskTimeBlock.startDate = NSDate(timeIntervalSince1970: startDate)
        }
        if let endDate = json["endDate"].double {
            taskTimeBlock.endDate = NSDate(timeIntervalSince1970: endDate)
        }

        let suggestedEvent = SuggestedEvent(taskTimeBlock: taskTimeBlock)
        return suggestedEvent
    }
}
