//
//  RequestFactory.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2018/05/27.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import Foundation
import Alamofire
import NSURL_QueryDictionary
import Result

class RequestFactory {

    var session: URLSession {
        let sessionConfigure = URLSessionConfiguration.default
        return URLSession(configuration: sessionConfigure)
    }

    var url: URL {
        return URL(string: "https://nowplayingios.firebase.com")!
    }

    var method: HTTPMethod {
        return .get
    }

    var dictionary: Parameters {
        return [:]
    }

    func fetch(handler: @escaping (APIResult) -> Void) {
        guard let targetUrl = try? (url as NSURL).uq_URL(byAppendingQueryDictionary: dictionary).asURL(),
            let request = try? URLRequest(url: targetUrl, method: method) else {
                let error = AnyError(NSError(domain: "RequestFactoryError", code: 1, userInfo: nil))
                handler(APIResult(error: error))
            return
        }

        commonRequest(request) {
            handler($0)
        }
    }

    func send(handler: @escaping (APIResult) -> Void) {
        guard var request = try? URLRequest(url: url, method: method) else {
            let error = AnyError(NSError(domain: "RequestFactoryError", code: 1, userInfo: nil))
            handler(APIResult(error: error))
            return
        }
        request.httpBody = try? JSONSerialization.data(withJSONObject: dictionary, options: .init(rawValue: 0))

        commonRequest(request) {
            handler($0)
        }
    }

    private func commonRequest(_ request: URLRequest, handler: @escaping (APIResult) -> Void) {
        var request = request
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode.isSuccessStatusCode {
                handler(APIResult(value: APIResponse(from: data, urlResponse: urlResponse)))
            } else {
                let error = error ?? NSError(domain: "APIRequestError", code: 2, userInfo: nil)
                handler(APIResult(error: AnyError(error)))
            }
        }
        task.resume()
    }
}
