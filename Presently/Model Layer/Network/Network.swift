//
//  Network.swift
//  Presently
//
//  Created by Thomas Patrick on 8/2/23.
//

import Foundation

typealias NetworkResult<T: Decodable> = Result<T, NetworkError>

struct Network {
    static let baseURL = Constant.baseURL
    
    static func load<ResultType: Decodable>(_ request: NetworkRequest<ResultType>) async -> NetworkResult<ResultType> {
        do {
            let (data, response) = try await URLSession.shared.data(for: request.urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Malformed response from backend (non-httpResponse)")
                return .failure(.serverError(code: -1, url: request.url()))
            }
            guard httpResponse.statusCode == 200 else {
                print("Received non-200 response code from network")
                print("URL:\n" + (String(describing: response.url)))
                print("REQUEST BODY:\n" + (String(data: request.urlRequest.httpBody ?? "(no body)".data(using: .utf8)!, encoding: .utf8) ?? "(string decoding error)"))
                print("RESPONSE BODY:\n" + (String(data: data, encoding: .utf8) ?? "(no body)"))
                return .failure(.serverError(code: httpResponse.statusCode, url: request.url()))
            }
            do {
                return .success(try JSONDecoder().decode(ResultType.self, from: data))
            } catch {
                return .failure(.decoding(error, url: request.url()))
            }
        } catch {
            print("Unknown network error")
            return .failure(.unknown(error, url: request.url()))
        }
    }
}
