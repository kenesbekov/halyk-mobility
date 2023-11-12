//
//  AppProvider.swift
//  Halyk Mobility
//
//  Created by Adam Kenesbekov on 11.11.2023.
//

import Foundation
import SwiftUI
import UIKit


protocol OrderProvider: AnyObject {
    func getMobileKinds(for destination: Destination) -> [MobileKind]
    func getTrip(for mobileKind: MobileKind) -> Trip
    func makeTaxiOrder() -> TaxiOrderResponse
    func getTaxiStatus(with id: Int) -> TaxiStatus
}

protocol CarRecognitionProvider: AnyObject {
    func getImageLabeling(image: UIImage, label: String) async throws -> String
}

typealias ChatMessage = String

enum MessageRoleKind: String, Decodable {
    case chatBot
    case user
}

struct ChatBotHistory: Decodable {
    struct Item: Decodable {
        let id = UUID()
        let roleKind: MessageRoleKind
        let message: ChatMessage
    }

    let items: [Item]
}

struct MessageResponse: Decodable {
    let roleKind: MessageRoleKind
    let messageKind: MessageKind
}

enum MessageKind: Decodable {
    private enum CodingKeys: String, CodingKey {
        case kind
        case message
        case hints
    }

    case sendMessage(ChatMessage)
    case hints([ChatMessage])

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let kind = try container.decode(String.self, forKey: .kind)
        switch kind {
        case "SEND_MESSAGE":
            let message = try container.decode(ChatMessage.self, forKey: .message)
            self = .sendMessage(message)
        case "HINTS":
            let hints = try container.decode([ChatMessage].self, forKey: .hints)
            self = .hints(hints)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .kind,
                in: container,
                debugDescription: "Unknown \(kind)"
            )
        }
    }
}

typealias ChatID = Int

struct SendMessageRequest: Encodable {
    let chatId: ChatID
    let message: ChatMessage
}

struct SendMessageResponse: Decodable {
    let message: ChatMessage
}

protocol ChatBotProvider: AnyObject {
    func create() async throws -> ChatID
    func sendMessage(with request: SendMessageRequest) async throws -> SendMessageResponse
}

final class AppManager {
    let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
}

extension AppManager: ChatBotProvider {
    func create() async throws -> ChatID {
        let urlString = "/create-chat"
        return try await networkClient.get(urlString: urlString)
    }

    func sendMessage(with request: SendMessageRequest) async throws -> SendMessageResponse {
        let urlString = "/send-message"
        return try await networkClient.post(urlString: urlString, body: request)
    }
}

extension AppManager: CarRecognitionProvider {
    func getImageLabeling(image: UIImage, label: String) async throws -> String {
        print("start get image")

        let urlString = "/imageLabelingEndpoint"

        guard
            let imageData = image.jpegData(compressionQuality: 1.0),
            let labelData = label.data(using: .utf8)
        else {
            throw NetworkError.noDataReceived
        }

        let boundary = UUID().uuidString

        var body = Data()

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"label\"\r\n\r\n")
        body.append(labelData)
        body.append("\r\n")

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")

        body.append("--\(boundary)--\r\n")

        let result: String = try await networkClient.post(
            urlString: urlString,
            body: body,
            boundary: boundary
        )
        return result
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}


private enum Mocks {
    static var mobileKinds: [MobileKind] {
        [
            .airplane,
            .bike,
            .taxi
        ]
    }
    static var trip: Trip {
        .init(
            beforeMain: beforeMain,
            main: beforeMain,
            afterMain: beforeMain
        )
    }
    static var beforeMain: TripItem {
        .init(
            mobileKind: .samokat,
            esitematedTime: 20,
            destination: nil
        )
    }
    static var car: Car {
        .init(
            name: "Toyota Corolla",
            color: "Синий",
            number: "L1020SFD"
        )
    }
    static var taxiOrderResponse: TaxiOrderResponse {
        .init(
            car: car,
            orderID: 1
        )
    }
    static var taxiStatus: TaxiStatus {
        .init(
            estimatedTime: 5,
            driverLocation: .init(longitude: 12.3, latitude: 123.3)
        )
    }
}
