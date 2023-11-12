//
//  NetworkClient.swift
//  Halyk Mobility
//
//  Created by Adam Kenesbekov on 11.11.2023.
//

import Foundation
import SwiftUI

private enum Constants {
    static let baseURL = "http://192.168.237.91:3000"
}

class NetworkClient {
    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func get<T: Decodable>(urlString: String) async throws -> T {
        guard var urlRequest = try makeUrlRequest(with: urlString) else {
            throw NetworkError.invalidURL
        }

        print("getting urlRequest:", urlRequest.url?.absoluteString)

        urlRequest.httpMethod = "GET"

        let result: (data: Data, response: URLResponse) = try await session.data(for: urlRequest)

        print("url response:", result)
        try validateStatusCode(result.response)

        return try JSONDecoder().decode(T.self, from: result.data)
    }

    // CarRecognition
    func post<T: Decodable>(urlString: String, body: Data, boundary: String) async throws -> T {
        guard var urlRequest = try makeUrlRequest(with: urlString) else {
            throw NetworkError.invalidURL
        }

        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = body

        let result: (data: Data, response: URLResponse) = try await session.data(for: urlRequest)
        try validateStatusCode(result.response)

        return try JSONDecoder().decode(T.self, from: result.data)
    }

    func post<T: Decodable>(urlString: String, body: Encodable) async throws -> T {
        guard var urlRequest = try makeUrlRequest(with: urlString) else {
            throw NetworkError.invalidURL
        }

        let encoded = try JSONEncoder().encode(body)

        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = encoded

        let result: (data: Data, response: URLResponse) = try await session.data(for: urlRequest)
        try validateStatusCode(result.response)


        return try JSONDecoder().decode(T.self, from: result.data)
    }

    func post<T: Decodable>(urlString: String, body: Data) async throws -> T {
        guard var urlRequest = try makeUrlRequest(with: urlString) else {
            throw NetworkError.invalidURL
        }

        urlRequest.httpMethod = "POST"

        let encoded = try JSONEncoder().encode(body)
        urlRequest.httpBody = encoded

        let result: (data: Data, response: URLResponse) = try await session.data(for: urlRequest)
        try validateStatusCode(result.response)


        return try JSONDecoder().decode(T.self, from: result.data)
    }

    func postMultiplatform<T: Decodable>(urlString: String, body: Data, boundary: String) async throws -> T {
        guard var urlRequest = try makeUrlRequest(with: urlString) else {
            throw NetworkError.invalidURL
        }

        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = body

        let result: (data: Data, response: URLResponse) = try await session.data(for: urlRequest)
        try validateStatusCode(result.response)

        return try JSONDecoder().decode(T.self, from: result.data)
    }

    private func makeUrlRequest(with urlString: String) throws -> URLRequest? {
        let urlString = Constants.baseURL + urlString

        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        return URLRequest(url: url)
    }

    private func validateStatusCode(_ response: URLResponse?) throws {
        let statusCode = (response as? HTTPURLResponse)?.statusCode

        print("Status code:", statusCode)

        guard let code = statusCode, (200..<300) ~= code else {
            throw NetworkError.serverError(statusCode: statusCode)
        }
    }
}
