//
//  NotificationManager.swift
//  tesWatch
//
//  Created by Yimei Winata on 26/06/26.
//

import UserNotifications

final class NotificationManager
{
    static let shared = NotificationManager()
    
    private init() {}
    func requestPermission() async  {
        do {
            try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print(error)
        }
    }
    
    func scheduleTimer(after seconds: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "Ready!"
        content.body = "Time is up!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(seconds),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print(error)
        }
        
    }
    
}
