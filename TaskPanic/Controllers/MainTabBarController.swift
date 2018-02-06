//
//  MainTabController.swift
//  TaskPanic
//
//  Created by Kris Kelly on 3/1/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // FIXME: Unbreak this when time to test against staging / prod
        let API_BASE_URL = "http://localhost:3000"

        let eventManager = EventKitManager()
        let calendarService = CalendarService(eventManager: eventManager)
        let taskService = TaskService()
        let apiWrapper = ApiWrapper(baseURL: API_BASE_URL, debug: false)
//        ApiWrapper.defaultWrapper(apiWrapper)
        let suggestionRequest = SuggestionRequest(apiWrapper: apiWrapper)
        let suggestionService = SuggestionService(suggestionRequest: suggestionRequest, taskService: taskService)
        let localSyncService = LocalSyncService(eventManager: eventManager, taskService: taskService)
//
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let dayPlannerMainViewController:  DayPlannerMainViewController = sb.instantiateViewController(withIdentifier: "DayPlannerMainViewController") as! DayPlannerMainViewController
        dayPlannerMainViewController.calendarService = calendarService
        dayPlannerMainViewController.eventManager = eventManager
        dayPlannerMainViewController.suggestionService = suggestionService
        dayPlannerMainViewController.taskService = taskService

        let taskListViewController: TaskListViewController = sb.instantiateViewController(withIdentifier: "TaskListViewController") as! TaskListViewController
        taskListViewController.taskService = taskService
        let taskListNavController = UINavigationController(rootViewController: taskListViewController)

        setViewControllers([
            taskListNavController,
            dayPlannerMainViewController,
        ], animated: true)
    }

}
