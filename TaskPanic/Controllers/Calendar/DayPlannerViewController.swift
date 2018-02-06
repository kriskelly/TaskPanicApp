//
//  DayPlannerViewController.swift
//  TaskPanic
//
//  Created by Kris Kelly on 4/28/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import UIKit

class DayPlannerViewController: UIViewController {

    let EVENT_CELL_REUSE_IDENTIFIER = "EventCellReuseIdentifier"

    var dayPlannerView: DayPlannerView!

    var calendarEvents: [DisplayableEvent] = []
    var eventManager: EventKitManager!
    var suggestedEvents: [DisplayableEvent] = []

    override func viewDidLoad() {
        self.dayPlannerView = DayPlannerView(frame: CGRect.zero)
        dayPlannerView.autoresizingMask = [.flexibleHeight, .flexibleWidth];
        dayPlannerView.delegate = self
        dayPlannerView.dataSource = self
        view.addSubview(dayPlannerView)
        dayPlannerView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        dayPlannerView.dayHeaderHeight = 0 // Hide the day header
        dayPlannerView.numberOfVisibleDays = 1
        dayPlannerView.register(AnyCalendarEventView.self, forEventViewWithReuseIdentifier: EVENT_CELL_REUSE_IDENTIFIER)
        dayPlannerView.showsAllDayEvents = false
        super.viewDidLoad()
    }

    func didLoadScheduledEvents(events: [DisplayableEvent], date: NSDate) {
        self.calendarEvents = events
        dayPlannerView.reloadAllEvents()
    }

    func didLoadSuggestedEvents(events: [DisplayableEvent], date: NSDate) {
        self.suggestedEvents = events
        dayPlannerView.reloadAllEvents()
    }
}


// MARK: - EventViewDelegate
extension DayPlannerViewController: EventViewDelegate {
    func eventDidSwipe(event: DisplayableEvent) {}
    func eventDidStartSwiping(event: DisplayableEvent) {}
    func eventWillRelease(event: DisplayableEvent) {}
    func eventDidCompleteRelease(event: DisplayableEvent) {}
    func eventDidChangeState(event: DisplayableEvent) {}
    
    func eventSwipeActivatedAction(event: DisplayableEvent, action: EventActionType) {
        if action == EventActionType.Accepted {
            print("Accepted the suggested event")
        } else if action == EventActionType.Rejected {
            print("Rejected the suggested event")
        }
    }
}
