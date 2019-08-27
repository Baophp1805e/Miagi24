//
//  NotificationManageViewController.swift
//  Miagi-Reminder
//
//  Created by Bao on 8/25/19.
//  Copyright © 2019 apple. All rights reserved.
//

import UIKit
import UserNotifications

final class NotificationManager: NSObject {
//    var addEvent: NewEventVC!
//    private var datePicker: UIDatePicker!
    static let shared = NotificationManager()
    let center = UNUserNotificationCenter.current()
    private override init() {
        super.init()
    }
//    @available(iOS 10.0, *)
//    private func registerDelegate() {
//        center.delegate = self
//    }
//
    
    func scheduleNotification(title: String, body: String, time: Date) {
        print("enable")
        center.delegate = self
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.badge = 1
        let identifier = "LocalNotification"
        //            .addingTimeInterval(-1.0 * 60.0)
        let selectedTime = time
        let triggerTime = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerTime, repeats: true)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    
    func scheduleNotifications(title: String, body: String, time: Date) {
        center.delegate = self
        print("enable")
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.badge = 1
        let identifier = "LocalNotifications"
        let selectedTime = time.addingTimeInterval(-1.0 * 60.0)
        let triggerTime = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerTime, repeats: true)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }
}
