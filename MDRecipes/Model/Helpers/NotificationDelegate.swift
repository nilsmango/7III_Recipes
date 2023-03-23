//
//  NotificationDelegate.swift
//  MDRecipes
//
//  Created by Simon Lang on 23.03.23.
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationDelegate: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    

    // This method will be called when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show an banner and play a sound
        completionHandler([.banner, .sound])
    }
}
