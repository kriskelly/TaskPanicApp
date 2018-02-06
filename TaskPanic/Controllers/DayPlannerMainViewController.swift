//
//  CalendarViewController.swift
//  TaskPanic
//
//  Created by Kris Kelly on 2/27/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import UIKit
import EventKit
import RealmSwift
import SnapKit

enum DragNotifications: String {
    case StartedDragging = "DidStartDragging"
    case DragPositionChanged = "DragPositionChanged"
    case Dropped = "DragWasDropped"
    case DragGestureKey = "DragGesture"
    case TaskKey = "Task"
    case ShadowedTaskViewKey = "ShadowedTaskView"
}

class DayPlannerMainViewController: UIViewController {

    let UNSCHEDULED_TASKS_SEGUE_IDENTIFIER = "unscheduledTasksView"

    var dragShadowView: CalendarDragShadowView!
    var dragShadowLongPressOffset: CGFloat!

    var calendarService: CalendarService!
    var eventManager: EventKitManager!
    var suggestionService: SuggestionService!
    var taskService: TaskService!
    var displayDate: Date!
    var calendarEvents: [CalendarEvent]?
    private var tasks: Results<Task>?

    weak var calendarViewController: DayPlannerViewController!
    weak var unscheduledTasksController: PendingTasksViewController!

    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var suggestButton: UIButton!
    @IBOutlet weak var unscheduledTasksView: UIView!
    @IBOutlet weak var unscheduledTasksHeightConstraint: NSLayoutConstraint!

    let PLANNER_SEGUE_IDENTIFIER = "dayPlannerView"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.displayDate = Date() // Today
        displayDisplayDate()
        observeDraggedTasks()
        suggestButton.addTarget(self, action: #selector(self.suggestTasks), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        fetchCalendarEvents()
        tasks = taskService.fetchIncompleteUnscheduledTasks()
        collapseUnscheduledTasksIfNecessary()
        unscheduledTasksController.tasks = tasks
    }

    @objc func suggestTasks() {
        suggestionService.fetchTimeBlocksForDate(date: displayDate, calendarEvents: calendarEvents!) {  [weak self] (suggestedEvents) in
            guard let s = self else { return }
            s.calendarViewController!.didLoadSuggestedEvents(events: suggestedEvents, date: s.displayDate as NSDate)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PLANNER_SEGUE_IDENTIFIER {
            calendarViewController = segue.destination as! DayPlannerViewController
        } else if segue.identifier == UNSCHEDULED_TASKS_SEGUE_IDENTIFIER {
            let controller = segue.destination as! PendingTasksViewController
            unscheduledTasksController = controller
        }
    }

    private func displayDisplayDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        currentDateLabel.text = dateFormatter.string(from: displayDate as Date)
    }

    private func fetchCalendarEvents() {
        calendarService.verifyAndLoadCalendarEvents(date: displayDate! as NSDate, completion: { [weak self] (events: [CalendarEvent]) -> Void in
            guard let s = self else { return }
            s.calendarEvents = events
            s.calendarViewController!.didLoadScheduledEvents(events: events, date: s.displayDate as NSDate)
        })
    }

    private func collapseUnscheduledTasksIfNecessary() {
        if let tasks = tasks {
            if tasks.count == 0 {
                unscheduledTasksView.isHidden = true
                unscheduledTasksHeightConstraint.constant = 0
            } else {
                unscheduledTasksView.isHidden = false
                unscheduledTasksHeightConstraint.constant = 100
            }

        }
    }

}

