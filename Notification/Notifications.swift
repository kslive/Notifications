//
//  Notifications.swift
//  Notification
//
//  Created by Eugene Kiselev on 24.09.2020.
//

import UIKit
import UserNotifications

class Notifications: NSObject, UNUserNotificationCenterDelegate {
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    func requestAuthorization() {
        
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self ](granted, error) in
            
            print("Granted: \(granted)")
            
            guard granted else { return }
            self?.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        
        notificationCenter.getNotificationSettings { settings in
            
            print("Settings: \(settings)")
        }
    }
    
    func scheduleNotification(notificationType: String) {
        
        let content = UNMutableNotificationContent()
        let userAction = "User Action"
        
        content.title = notificationType
        content.body = "This is example how to create " + notificationType
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = userAction
    
        guard let path = Bundle.main.path(forResource: "photo", ofType: "jpg") else { return }
        let url = URL(fileURLWithPath: path)
        
        do {
            
            let attachment = try UNNotificationAttachment(identifier: "photo", url: url, options: nil)
            
            content.attachments = [attachment]
        } catch {
            
            print("The attachment cold not be load")
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            
            if let error = error {
                
                print("\(error.localizedDescription)")
            }
        }
        
        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        let deleteAction = UNNotificationAction(identifier: "Delete", title: "Delete", options: [.destructive])
        let category = UNNotificationCategory(identifier: userAction, actions: [snoozeAction, deleteAction], intentIdentifiers: [],options: [])
        
        notificationCenter.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.identifier == "Local Notification" {
            
            print("Local Notification with the Local Notification Identifier")
        }
        
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier :
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier :
            print("Default")
        case "Snooze" :
            print("Snooze")
            scheduleNotification(notificationType: "Reminder")
        case "Delete" :
            print("Delete")
        default :
            print("Unknown action")
        }
        
        completionHandler()
    }
}
