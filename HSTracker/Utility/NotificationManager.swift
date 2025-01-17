//
//  NotificationManager.swift
//  HSTracker
//
//  Created by Istvan Fehervari on 17/04/2017.
//  Copyright © 2017 Benjamin Michotte. All rights reserved.
//

import Foundation

enum NotificationType {
    case gameStart, turnStart, opponentConcede, hsReplayPush(replayId: String), hsReplayUploadFailed(error: String),
         hsReplayCollectionUploaded, hsReplayMercenariesCollectionUploaded, hsReplayCollectionUploadFailed(error: String), hsReplayMercenariesCollectionUploadFailed(error: String), updateAvailable(version: String)
}

class NotificationManager {
    
    static func showNotification(type: NotificationType) {
        switch type {
        case .gameStart:
            guard Settings.notifyGameStart else {
                return
            }
            if CoreManager.isHearthstoneActive() {
                return
            }

            show(title: NSLocalizedString("Hearthstone", comment: ""),
                message: NSLocalizedString("Your game begins", comment: ""))

        case .opponentConcede:
            guard Settings.notifyOpponentConcede else {
                return
            }
            if CoreManager.isHearthstoneActive() {
                return
            }

            show(title: NSLocalizedString("Victory", comment: ""),
                message: NSLocalizedString("Your opponent have conceded", comment: ""))

        case .turnStart:
            guard Settings.notifyTurnStart else {
                return
            }
            if CoreManager.isHearthstoneActive() {
                return
            }

            show(title: NSLocalizedString("Hearthstone", comment: ""),
                message: NSLocalizedString("It's your turn to play", comment: ""))

        case .hsReplayPush(let replayId):
            guard Settings.showHSReplayPushNotification else {
                return
            }

            show(title: NSLocalizedString("HSReplay", comment: ""),
                message: NSLocalizedString("Your replay has been uploaded to HSReplay.net",
                    comment: "")) {
                HSReplayManager.showReplay(replayId: replayId)
            }

        case .hsReplayUploadFailed(let error):
            show(title: NSLocalizedString("HSReplay", comment: ""),
                 message: String(format: NSLocalizedString("Failed to upload replay: %@", comment: ""), "\(error)"))

        case .hsReplayCollectionUploaded:
            show(title: NSLocalizedString("HSReplay", comment: ""),
                message: NSLocalizedString("Your collection has been uploaded to HSReplay.net",
                    comment: ""))

        case .hsReplayCollectionUploadFailed(let error):
            show(title: NSLocalizedString("HSReplay", comment: ""),
                 message: String(format: NSLocalizedString("Failed to upload collection: %@", comment: ""), "\(error)"), duration: 10, fontSize: 8)
            
        case .hsReplayMercenariesCollectionUploaded:
            show(title: NSLocalizedString("HSReplay", comment: ""),
                message: NSLocalizedString("Your Mercenaries collection has been uploaded to HSReplay.net",
                    comment: ""))

        case .hsReplayMercenariesCollectionUploadFailed(let error):
            show(title: NSLocalizedString("HSReplay", comment: ""),
                 message: String(format: NSLocalizedString("Failed to upload Mercenaries collection: %@", comment: ""), "\(error)"), duration: 10, fontSize: 8)
            
        case .updateAvailable(let version):
            show(title: NSLocalizedString("A new update is available", comment: ""),
                 message: String(format: NSLocalizedString("Version %@ is now available", comment: ""), version), duration: 30, action: {
                AppDelegate.instance().sparkleUpdater.checkForUpdates(nil)
            })
        }
    }

    private static var notificationDelegate = NotificationDelegate()
    private static func show(title: String, message: String, duration: Double? = 3, fontSize: Int? = 14,
                             action: (() -> Void)? = nil) {
        if Settings.useToastNotification {
            Toast.show(title: title, message: message, duration: duration, fontSize: fontSize, action: action)
        } else {
            let notification = NSUserNotification()
            notification.title = title
            notification.subtitle = ""
            notification.informativeText = message

            if action != nil {
                notification.actionButtonTitle = NSLocalizedString("Show", comment: "")
                notification.hasActionButton = true
                notificationDelegate.action = action
                NSUserNotificationCenter.default.delegate = notificationDelegate
            }
            
            notification.deliveryDate = Date()
            NSUserNotificationCenter.default.scheduleNotification(notification)
        }
    }

    private class NotificationDelegate: NSObject, NSUserNotificationCenterDelegate {
        var action: (() -> Void)?

        func userNotificationCenter(_ center: NSUserNotificationCenter,
                                    didActivate notification: NSUserNotification) {
            self.action?()
        }
    }
    
}
