//
//  LocalNotificationManager.swift
//  LocationTracker
//
//  Created by Denny Mathew on 28/03/20.
//  Copyright © 2020 Densigns. All rights reserved.
//

import Foundation
import UserNotifications

class LocalNotificationManager {
    let center = UNUserNotificationCenter.current()
    func requestPermission() {
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
        }
    }
    func postNotification(_ location: Location) {
        let content = UNMutableNotificationContent()
        content.title = "New Journal entry 📌"
        content.body = location.description
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: location.dateString, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: nil)
    }
}
