//
//  TaxiOrderResponse.swift
//  Halyk Mobility
//
//  Created by Adam Kenesbekov on 11.11.2023.
//

import Foundation

struct TaxiOrderResponse {
    typealias OrderID = Int

    let car: Car
    let orderID: OrderID
}
