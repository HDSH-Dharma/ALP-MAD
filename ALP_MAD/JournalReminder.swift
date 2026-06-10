//
//  JournalReminder.swift
//  ALP_MAD
//
//  Created by Dharma on 11/06/26.
//

import Foundation
import UserNotifications

/// Abstraction over the notification system so the reminder logic can be
/// unit tested with a mock (dependency injection).
protocol UserNotificationScheduling {
    func requestAuthorization() async -> Bool
    func add(_ request: UNNotificationRequest) async
    func removePending(identifiers: [String])
}

/// Real implementation backed by UNUserNotificationCenter.
struct SystemNotificationScheduler: UserNotificationScheduling {
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
    }

    func add(_ request: UNNotificationRequest) async {
        try? await center.add(request)
    }

    func removePending(identifiers: [String]) {
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}

/// Schedules a daily "write your journal" reminder. Appears on the iPhone and,
/// for a paired Apple Watch, mirrors to the wrist automatically.
final class JournalReminder {

    static let identifier = "journal.daily.reminder"

    private let scheduler: UserNotificationScheduling

    init(scheduler: UserNotificationScheduling = SystemNotificationScheduler()) {
        self.scheduler = scheduler
    }

    /// Builds the repeating daily reminder request. Pure & testable.
    static func makeDailyRequest(hour: Int, minute: Int) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = "Tulis Jurnal Hari Ini"
        content.body  = "Abadikan momen perjalananmu sebelum terlupa ✍️"
        content.sound = .default

        var components = DateComponents()
        components.hour   = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }

    /// Requests permission (once) and schedules the daily reminder, replacing
    /// any previous one so it never stacks.
    func scheduleDailyReminder(hour: Int = 20, minute: Int = 0) async {
        guard await scheduler.requestAuthorization() else { return }
        scheduler.removePending(identifiers: [Self.identifier])
        await scheduler.add(Self.makeDailyRequest(hour: hour, minute: minute))
    }

    func cancel() {
        scheduler.removePending(identifiers: [Self.identifier])
    }
}
