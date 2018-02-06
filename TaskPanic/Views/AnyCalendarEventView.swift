//
//  AnyCalendarEventView.swift
//  TaskPanic
//
//  Created by Kris Kelly on 5/7/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import UIKit
import CalendarLib

enum EventType {
    case Calendar
    case ScheduledTask
    case SuggestedTask
}

class AnyCalendarEventView: MGCEventView {
    var event: DisplayableEvent?
    weak var delegate: EventViewDelegate?

    var calendarEventView: MGCStandardEventView?
    var suggestedEventView: SuggestedEventView?
    var taskEventView: TaskEventView?

    // MARK: - Properties for compatibility with MGCStandardEventView (temporary)

    var title: String?
    var color: UIColor?
    var style: MGCStandardEventViewStyle!
    var font: UIFont?

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = nil // MGCEventView is gray by default
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        calendarEventView?.frame = self.frame
        suggestedEventView?.frame = self.frame
        taskEventView?.frame = self.frame
    }

    /**
     Copy an event view correctly.
     
     This is used by the underlying CalendarLib to create an interactive cell when moving events around.

    */
    override func copy(with zone: NSZone? = nil) -> Any {
        let cell: AnyCalendarEventView = super.copy(with: zone) as! AnyCalendarEventView
        cell.title = title
        if let font = font {
            cell.font = font
        }
        cell.color = color
        cell.style = style
        cell.delegate = delegate
        cell.initWithEvent(event: event!)
        return cell
    }

    func initWithEvent(event: DisplayableEvent) {
        self.event = event
        if event is CalendarEvent {
            initWithCalendarEvent(event: event as! CalendarEvent)
        } else if event is TaskEvent {
            initWithTaskEvent(event: event as! TaskEvent)
        } else {
            initWithSuggestedEvent(event: event as! SuggestedEvent)
        }
    }

    private func initWithCalendarEvent(event: CalendarEvent) {
        let calendarEventView = MGCStandardEventView(frame: self.frame)
        calendarEventView.title = title
        if let color = color {
            calendarEventView.color = color
        } else {
            calendarEventView.color = UIColor(cgColor: event.calendar!.cgColor)
        }
        calendarEventView.style = style!
        calendarEventView.font = font
        addSubview(calendarEventView)
        self.calendarEventView = calendarEventView
    }

    private func initWithSuggestedEvent(event: SuggestedEvent) {
        let suggestedEventView = SuggestedEventView(frame: self.frame)
        suggestedEventView.delegate = delegate
        suggestedEventView.event = event
        suggestedEventView.title = title
        if let color = color {
            suggestedEventView.color = color
        }
        suggestedEventView.style = style!
        suggestedEventView.font = font
        addSubview(suggestedEventView)
        self.suggestedEventView = suggestedEventView
    }

    private func initWithTaskEvent(event: TaskEvent) {
        let taskEventView = TaskEventView(frame: self.frame)
        taskEventView.delegate = delegate
        taskEventView.event = event
        taskEventView.title = title
        if let color = color {
            taskEventView.color = color
        }
        taskEventView.style = style!
        taskEventView.font = font
        addSubview(taskEventView)
        self.taskEventView = taskEventView
    }
}
