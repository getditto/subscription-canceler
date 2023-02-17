//
//  Car.swift
//  SubscriptionCanceler
//
//  Created by Maximilian Alexander on 2/16/23.
//

import Foundation
import DittoSwift

enum Brand: String, CaseIterable {
    case acura
    case bentley
    case cadillac
    case dodge
}

struct Car: Identifiable {

    var id: String
    var brand: String
    var color: String
    var mileage: Int
}

extension Car {

    init(document: DittoDocument) {
        self.id = document.id.stringValue
        self.color = document["color"].stringValue
        self.mileage = document["mileage"].intValue
        self.brand = document["brand"].stringValue
    }

    var asDittoDocumentDictionary: [String: Any?] {
        return [
            "_id": id,
            "color": color,
            "mileage": mileage,
            "brand": brand
        ]
    }
}

