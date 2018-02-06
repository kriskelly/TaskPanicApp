//
//  NSDateExtension.swift
//  TaskPanic
//
//  Created by Kris Kelly on 3/26/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import Foundation

extension Date {
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self as Date)
    }
    
    func endOfDay() -> Date {
        // Components to calculate end of day
        var components = DateComponents()
        components.day = 1
        components.second = -1
        
        // Last moment of a given date
        return Calendar.current.date(byAdding: components, to: startOfDay() as Date)!
    }
}
