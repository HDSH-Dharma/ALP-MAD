//
//  JournalReminderTests.swift
//  ALP_MAD
//
//  Created by Dharma on 11/06/26.
//

import Testing
import Foundation
import UserNotifications
@testable import ALP_MAD

// MARK: - Mock

final class MockNotificationScheduler: UserNotificationScheduling, @unchecked Sendable {
    var authorized = true
    var authRequested = false
    var addedRequests: [UNNotificationRequest] = []
    var removedIdentifiers: [String] = []

    func requestAuthorization() async -> Bool {
        authRequested = true
        return authorized
    }

    func add(_ request: UNNotificationRequest) async {
        addedRequests.append(request)
    }

    func removePending(identifiers: [String]) {
        removedIdentifiers.append(contentsOf: identifiers)
    }
}

// MARK: - Tests

@Suite("Journal Reminder")
struct JournalReminderTests {

    @Test("Daily request has the correct content and identifier")
    func dailyRequestContent() {
        let request = JournalReminder.makeDailyRequest(hour: 20, minute: 0)
        #expect(request.identifier == JournalReminder.identifier)
        #expect(request.content.title == "Tulis Jurnal Hari Ini")
        #expect(!request.content.body.isEmpty)
    }

    @Test("Daily request repeats at the given time")
    func dailyRequestTrigger() throws {
        let request = JournalReminder.makeDailyRequest(hour: 9, minute: 30)
        let trigger = try #require(request.trigger as? UNCalendarNotificationTrigger)
        #expect(trigger.repeats == true)
        #expect(trigger.dateComponents.hour == 9)
        #expect(trigger.dateComponents.minute == 30)
    }

    @Test("Scheduling when authorized adds the reminder and clears the old one")
    func scheduleAuthorized() async {
        let mock = MockNotificationScheduler()
        mock.authorized = true
        let reminder = JournalReminder(scheduler: mock)

        await reminder.scheduleDailyReminder(hour: 20, minute: 0)

        #expect(mock.authRequested == true)
        #expect(mock.removedIdentifiers == [JournalReminder.identifier])
        #expect(mock.addedRequests.count == 1)
        #expect(mock.addedRequests.first?.identifier == JournalReminder.identifier)
    }

    @Test("Scheduling when denied does not add a reminder")
    func scheduleDenied() async {
        let mock = MockNotificationScheduler()
        mock.authorized = false
        let reminder = JournalReminder(scheduler: mock)

        await reminder.scheduleDailyReminder()

        #expect(mock.authRequested == true)
        #expect(mock.addedRequests.isEmpty)
    }

    @Test("Cancel removes the pending reminder")
    func cancel() {
        let mock = MockNotificationScheduler()
        let reminder = JournalReminder(scheduler: mock)

        reminder.cancel()

        #expect(mock.removedIdentifiers == [JournalReminder.identifier])
    }
}
