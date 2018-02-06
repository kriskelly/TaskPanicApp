//
//  CalendarLayoutUtils.swift
//  TaskPanic
//
//  Created by Kris Kelly on 3/26/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import Foundation

let SNAP_INTERVAL_MINUTES = 15.0

func calculateHeightFromDates(startDate: Date, endDate: Date, hourHeight: Double) -> Double {
    let seconds = endDate.timeIntervalSince(startDate as Date)
    return calculateHeightFromTimeLength(seconds: seconds, hourHeight: hourHeight)
}

func calculateHeightFromTimeLength(seconds: Double, hourHeight: Double) -> Double {
    return Double(roundSecondsToHours(seconds: seconds, roundingIntervalInMinutes: SNAP_INTERVAL_MINUTES)) * hourHeight
}

private func roundSecondsToHours(seconds: Double, roundingIntervalInMinutes: Double) -> Double {
    var roundedSeconds: Double
    if (seconds > 0) {
        roundedSeconds = floor(seconds / (roundingIntervalInMinutes * 60.0)) * roundingIntervalInMinutes * 60.0
    } else {
        roundedSeconds = ceil(seconds / (roundingIntervalInMinutes * 60.0)) * roundingIntervalInMinutes * 60.0
    }
    return roundedSeconds / 3600.0
}

func calculateYStartFromDate(startDate: Date, hourHeight: Double) -> Double {
    // NSDate is UTC, so calculate the offset from GMT and add that.
    let gmtStartY = calculateHeightFromDates(startDate: startDate.startOfDay(), endDate: startDate, hourHeight: hourHeight)
//    let tz = NSTimeZone.localTimeZone()
//    let gmtOffsetY = calculateHeightFromTimeLength(Double(tz.secondsFromGMTForDate(startDate)), hourHeight: hourHeight)
//    if (gmtOffsetY > 0) {
//        return gmtStartY + gmtOffsetY
//    } else {
//        return gmtStartY - gmtOffsetY
//    }
    return gmtStartY
}

//export function calculateTimeLengthFromPosition(yPos: number, hourHeight: number): number {
//    const hours = yPos / hourHeight;
//    return roundSecondsToHours(hours * 3600);
//}
//
//export function calculateDateFromPositionOffset(yOffset: number, originalDate: Date, hourHeight: number): Date {
//    const timeLengthInHours = calculateTimeLengthFromPosition(yOffset, hourHeight);
//    return moment(originalDate).add(timeLengthInHours, 'hours').toDate();
//}
//
//export function calculateDateFromHourOffset(hourOffset: number, originalDate: Date): Date {
//    return moment(originalDate).add(hourOffset, 'hours').toDate();
//}
