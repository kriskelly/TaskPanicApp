//
//  SuggestionRequest.swift
//  TaskPanic
//
//  Created by Kris Kelly on 5/14/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import Foundation

class SuggestionRequest {
    private let apiWrapper: ApiWrapper

    init(apiWrapper: ApiWrapper) {
        self.apiWrapper = apiWrapper
    }

    func fetch(tasks: [Task], startTime: Date, endTime: Date, calendarEvents: [CalendarEvent], completionHandler: @escaping (SuggestionResponse) -> Void) {

        let taskParams = getParams(for: tasks)
        let calendarEventParams = getCalendarEventParams(calendarEvents: calendarEvents)

        // Convert passed in parameters to an API call
        let postParams: [String: AnyObject] = [
            "tasks": taskParams as AnyObject,
            "calendarEvents": calendarEventParams as AnyObject,
            "startTime": startTime.timeIntervalSince1970 as AnyObject,
            "endTime": endTime.timeIntervalSince1970 as AnyObject
        ]

        apiWrapper.post(relativeURL: "/suggestions", params: postParams) { response in
            let suggestionResponse = SuggestionResponse(apiResponse: response)
            completionHandler(suggestionResponse)
        }
    }

    private func getCalendarEventParams(calendarEvents: [CalendarEvent]) -> [[String: AnyObject]] {
        return calendarEvents.map({ (calendarEvent) -> [String : AnyObject] in
            return [
                "start": calendarEvent.startDate.timeIntervalSince1970 as AnyObject,
                "end": calendarEvent.endDate.timeIntervalSince1970 as AnyObject
            ]
        })
    }

    private func getParams(for tasks: [Task]) -> [[String: AnyObject]] {
        return tasks.map { (task) -> [String : AnyObject] in
            // TODO: Include other params like priority, importance, deadline
            return [
                "id": task.id as AnyObject,
                "name": task.name as AnyObject,
                "duration": task.timeLength as AnyObject
            ]
        }
    }
}
