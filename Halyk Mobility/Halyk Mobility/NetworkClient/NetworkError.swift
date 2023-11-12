//
//  NetworkError.swift
//  Halyk Mobility
//
//  Created by Adam Kenesbekov on 11.11.2023.
//

import Foundation

enum NetworkError: Error {
    case serverError(statusCode: Int?)
    case noDataReceived
    case decodingError(DecodingError)
    case unknowError(Error)
    case invalidURL
}
