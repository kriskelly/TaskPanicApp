//
//  SuggestionService.swift
//  TaskPanic
//
//  Created by Kris Kelly on 5/14/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import Foundation

class SuggestionService {
    private let suggestionRequest: SuggestionRequest
    private let taskService: TaskService

    init(suggestionRequest: SuggestionRequest, taskService: TaskService) {
        self.suggestionRequest = suggestionRequest
        self.taskService = taskService
    }

    func fetchTimeBlocksForDate(date: Date, calendarEvents: [CalendarEvent], completionHandler: @escaping ([SuggestedEvent]) -> Void) {
        // TODO: Fetch tasks

        let startTime = date
        let endTime = date.endOfDay()
        // FIXME: This list may get arbitrarily large, find a better way to handle this.
        let results = taskService.fetchIncomplete()
        let tasks: [Task] = Array(results!)


        suggestionRequest.fetch(tasks: tasks, startTime: startTime, endTime: endTime, calendarEvents: calendarEvents) {
            response in

            completionHandler(response.suggestedEvents)
        }
    }
}
