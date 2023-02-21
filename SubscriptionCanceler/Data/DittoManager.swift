//
//  DittoManager.swift
//  SubscriptionCanceler
//
//  Created by Maximilian Alexander on 2/16/23.
//

import Foundation
import DittoSwift
import Fakery

class DittoManager {

    static let shared = DittoManager()

    let ditto: Ditto

    private init() {
        ditto = Ditto(identity: .onlinePlayground(appID: "ebda0d43-7bf8-4e6b-a88e-7cf4596d6a7f", token: "60fcd18a-3ea7-4140-8297-119f38a5bae9"))
        let isPreview: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        if !isPreview {
          // non preview simulators and real devices can sync
          try? ditto.startSync()
        }
    }

}
