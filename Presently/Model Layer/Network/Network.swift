//
//  Network.swift
//  Presently
//
//  Created by Thomas Patrick on 8/2/23.
//

import Foundation

typealias NetworkResult<T: Decodable> = Result<T, NetworkError>

struct Network {
    static let baseURL = "https://4vbocehon3.execute-api.us-east-2.amazonaws.com/"
    
    static func load<ResultType: Decodable>(request: NetworkRequest<ResultType>) async -> NetworkResult<ResultType> {
        do {
            let (data, response) = try await URLSession.shared.data(for: request.urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Malformed response from backend (non-httpResponse)")
                return .failure(.serverError(code: -1, url: request.url()))
            }
            guard httpResponse.statusCode == 200 else {
                print("Non-200 response code while fetching exchange: \n\(response)")
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
