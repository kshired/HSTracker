//
//  Sentry.swift
//  HSTracker
//
//  Created by Francisco Moraes on 7/8/22.
//  Copyright © 2022 Benjamin Michotte. All rights reserved.
//

import Foundation
import AppCenterCrashes

class Sentry {
    struct BobsBuddyEvent {
        let type: String
        let message: String
        var properties: [String: String]
        let input: String
        let log: String
    }
    
    static let maxBobsBuddyEvents = 10
    static var bobsBuddyEventsSent = 0
    
    private static var bobsBuddyEvents = SynchronizedArray<BobsBuddyEvent>()
    
    static func queueBobsBuddyTerminalCase(type: String, message: String, properties: [String: String], input: String, log: String) {
        if bobsBuddyEventsSent >= maxBobsBuddyEvents {
            return
        }
        
        let data = BobsBuddyEvent(type: type, message: message, properties: properties, input: input, log: log)
        bobsBuddyEvents.append(data)        
    }
    
    static func sendQueuedBobsBuddyEvents(shortId: String?) {
        while bobsBuddyEvents.count > 0 {
            if bobsBuddyEventsSent >= maxBobsBuddyEvents {
                clearBobsBuddyEvents()
                break
            }
            var e = bobsBuddyEvents.removeFirst()
            if let shortId = shortId {
                e.properties["shortId"] = shortId
                e.properties["replay"] = "https://hsreplay.net/replay_debug/\(shortId)#turn=\(e.properties["turn"] ?? "0")b"
            }
            Crashes.trackException(ExceptionModel.init(withType: e.type, exceptionMessage: e.message, stackTrace: []), properties: e.properties, attachments: [ErrorAttachmentLog.init(filename: "input.cs", attachmentText: e.input), ErrorAttachmentLog.init(filename: "log.txt", attachmentText: e.log)])
            bobsBuddyEventsSent += 1
        }
    }
    
    static func clearBobsBuddyEvents() {
        bobsBuddyEvents.removeAll()
    }
}
