//
//  NetworkRequest.swift
//  Presently
//
//  Created by Thomas Patrick on 8/2/23.
//

import Foundation

struct NetworkRequest<ResultType: Decodable> {
    var urlRequest: URLRequest
    let resultType: ResultType.Type
    func url() -> String { urlRequest.url?.absoluteString ?? "no url" }
    
    init?<BodyType: Encodable>(method: NetworkRequestMethod = .get, path: String, body: BodyType, resultType: ResultType.Type) {
        guard let requestURL = URL(string: Network.baseURL)?.appending(path: path) else {
            print("Error creating URL from path: \(path)")
            return nil
        }
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let bodyData = try JSONEncoder().encode(body)
            request.httpBody = bodyData
        } catch {
            print("Error encoding body for path: \(path)\nObject: \(body)\nError:\(error)")
            return nil
        }
        
        self.urlRequest = request
        self.resultType = resultType
    }
    
    init?(method: NetworkRequestMethod = .get, path: String, resultType: ResultType.Type) {
        guard let requestURL = URL(string: Network.baseURL)?.appending(path: path) else {
            print("Error creating URL from path: \(path)")
            return nil
        }
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        self.urlRequest = request
        self.resultType = resultType
    }
}

enum NetworkRequestMethod: String {
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
}
