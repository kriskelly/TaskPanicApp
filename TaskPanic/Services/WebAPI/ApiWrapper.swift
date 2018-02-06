//
//  ApiWrapper.swift
//  TaskPanic
//
//  Created by Kris Kelly on 5/14/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import Foundation
import Alamofire

class ApiWrapper {

    private let debug: Bool
    private let baseURL: String

    init(baseURL: String, debug: Bool = false) {
        self.baseURL = baseURL
        self.debug = debug
    }

    func post(relativeURL: String, params: [String: Any]? = nil, completionHandler: (DataResponse<AnyObject>) -> Void) {
        let url = "\(baseURL)\(relativeURL)"
        let request = Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default)
        if debug == true {
            debugPrint(request)
        }
    }
}
