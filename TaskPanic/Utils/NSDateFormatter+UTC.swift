//
//  NSDateFormatter+UTC.swift
//  TaskPanic
//
//  Created by Kris Kelly on 5/16/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import Foundation

extension DateFormatter {
    func setDateFormatToUTC() {
        dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    }
}
