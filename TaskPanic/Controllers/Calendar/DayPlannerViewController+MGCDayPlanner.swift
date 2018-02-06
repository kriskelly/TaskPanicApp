//
//  DayPlannerViewController+MGCDayPlanner.swift
//  TaskPanic
//
//  Created by Kris Kelly on 6/11/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import Foundation
import CalendarLib


// MARK: - MGCDayPlannerViewDataSource
extension DayPlannerViewController: MGCDayPlannerViewDataSource {
    /*!
    	@abstract	Asks the data source for the number of events of given type at specified date. (required)
    	@param		view		The day planner view object making the request.
    	@param		type		The type of the event.
    	@param		date		The starting day of the event (time portion should be ignored).
    	@return		The number of events.
     */
    public func dayPlannerView(_ view: MGCDayPlannerView!, numberOfEventsOf type: MGCEventType, at date: Date!) -> Int {
        // FIXME: Ignore the event type for now.
        return calendarEvents.count + suggestedEvents.count
    }


    func eventAtIndex(index: UInt) -> DisplayableEvent {
        if Int(index) < calendarEvents.count {
            return calendarEvents[Int(index)]
        } else {
            let suggestionIndex = Int(index) - calendarEvents.count
            return suggestedEvents[suggestionIndex]
        }
    }

    func dayPlannerView(_ view: MGCDayPlannerView!, viewForEventOf type: MGCEventType, at index: UInt, date: Date!) -> MGCEventView! {
        let displayableEvent: DisplayableEvent = eventAtIndex(index: index)
        let cell = view.dequeueReusableView(withIdentifier: EVENT_CELL_REUSE_IDENTIFIER, forEventOf: MGCEventType.timedEventType, at: index, date: date as Date!) as! AnyCalendarEventView

        cell.event = displayableEvent
        cell.font = UIFont.systemFont(ofSize: 11)
        cell.title = displayableEvent.title
        cell.style = MGCStandardEventViewStyle.plain
        cell.delegate = self
        cell.initWithEvent(event: displayableEvent)
        return cell
    }

    func dayPlannerView(_ view: MGCDayPlannerView!, dateRangeForEventOf type: MGCEventType, at index: UInt, date: Date!) -> MGCDateRange! {
        let event: DisplayableEvent = eventAtIndex(index: index)
        return MGCDateRange(start: event.startDate as Date!, end: event.endDate as Date!)
    }

    func dayPlannerView(_ view: MGCDayPlannerView!, shouldStartMovingEventOf type: MGCEventType, at index: UInt, date: Date!) -> Bool {
        let event: DisplayableEvent = eventAtIndex(index: index)
        return event.calendar?.allowsContentModifications ?? false
    }

    func dayPlannerView(_ view: MGCDayPlannerView!, canMoveEventOf type: MGCEventType, at index: UInt, date: Date!, to targetType: MGCEventType, date targetDate: Date!) -> Bool {
        let event: DisplayableEvent = eventAtIndex(index: index)
        return event.calendar!.allowsContentModifications
    }

    func dayPlannerView(_ view: MGCDayPlannerView!, moveEventOf type: MGCEventType, at index: UInt, date: Date!, to targetType: MGCEventType, date targetDate: Date!) {
        let event: DisplayableEvent = eventAtIndex(index: index)

        let dates = recalculateEventDates(event: event, targetDate: targetDate as NSDate)
        event.startDate = dates.startDate
        event.endDate = dates.endDate
        print("FIXME: moveEventOfType() Save the event using the calendar service")
        // FIXME: Save the event using the calendar service
        // Don't forget to call endInteraction on dayPlannerView when you're done
        dayPlannerView.endInteraction()
    }

    func dayPlannerView(_ view: MGCDayPlannerView!, viewForNewEventOf type: MGCEventType, at date: Date!) -> MGCEventView! {
        let calendar = eventManager.defaultCalendar
        let cell = MGCStandardEventView()
        cell.title = "New Event"
        cell.color = UIColor(cgColor: calendar.cgColor)
        return cell
    }

    func dayPlannerView(_ view: MGCDayPlannerView!, createNewEventOf type: MGCEventType, at date: Date!) {
        let event = eventManager.newEvent()
        event.startDate = date as Date
        var dateComponents = DateComponents()
        dateComponents.hour = 1
        let calendar = NSCalendar.current
        event.endDate = calendar.date(byAdding: dateComponents, to: date as Date)!
        event.isAllDay = false
        print("FIXME: Would have created a new event here")
    }

    private func recalculateEventDates(event: DisplayableEvent, targetDate: NSDate) -> (startDate: NSDate, endDate: NSDate) {
        let calendar = NSCalendar.current
//        let components = Set<>([DateComponents.minute])
        let components = Set<Calendar.Component>([Calendar.Component.minute])
        let duration = calendar.dateComponents(components, from: event.startDate as Date, to: event.endDate as Date)
        let end = calendar.date(byAdding: duration, to: targetDate as Date)
        return (startDate: targetDate, endDate: end! as NSDate)
    }
}

// MARK: - MGCDayPlannerViewDelegate
extension DayPlannerViewController: MGCDayPlannerViewDelegate {

    func dayPlannerView(_ view: MGCDayPlannerView!, didSelectEventOf type: MGCEventType, at index: UInt, date: Date!) {
        print("FIXME: didSelectEventOfType() Do something here")
    }

    func dayPlannerView(_ view: MGCDayPlannerView!, willDisplay date: Date!) {
        print("FIXME: willDisplayDate() Do something here")
    }

    func dayPlannerView(_ view: MGCDayPlannerView!, didEndDisplaying date: Date!) {
        print("FIXME: didEndDisplayingDate() Do something here")
    }
}
