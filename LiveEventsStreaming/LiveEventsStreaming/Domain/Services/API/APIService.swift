//
//  APIService.swift
//  LiveEventsStreaming
//
//  Created by Yves on 2025/9/18.
//

import Foundation
import Combine

protocol APIServiceProtocol {
    func request<T: Endpoint>(_ endpoint: T) -> AnyPublisher<T.Response, Error>
}

class URLSessionAPIService: APIServiceProtocol {
    func request<T: Endpoint>(_ endpoint: T) -> AnyPublisher<T.Response, Error> {
        guard let url = URL(string: endpoint.domain + endpoint.path) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.httpBody = endpoint.body
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: T.Response.self, decoder: JSONDecoder()) // 若 T.Response: Decodable
            .eraseToAnyPublisher()
    }
}

class MockAPIService: APIServiceProtocol {
    func request<T: Endpoint>(_ endpoint: T) -> AnyPublisher<T.Response, Error> {
        Fail<T.Response, Error>(error: NSError(domain: "it is mock service", code: 0))
            .eraseToAnyPublisher()
    }
}
