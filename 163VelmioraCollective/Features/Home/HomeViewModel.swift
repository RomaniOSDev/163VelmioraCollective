import Combine
import Foundation

final class HomeViewModel: ObservableObject {
    func greeting(for date: Date = Date()) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }

    func goalProgress(finished: Int, target: Int) -> Double {
        guard target > 0 else { return 0 }
        return min(1, Double(finished) / Double(target))
    }

    func recentShelfBooks(from books: [ShelfBook], limit: Int = 3) -> [ShelfBook] {
        let unread = books.filter { !$0.isRead }.sorted { $0.addedAt > $1.addedAt }
        if unread.count >= limit { return Array(unread.prefix(limit)) }
        let read = books.filter(\.isRead).sorted { $0.addedAt > $1.addedAt }
        return Array((unread + read).prefix(limit))
    }

    func recentLogEntries(from log: [ReadingLogEntry], limit: Int = 2) -> [ReadingLogEntry] {
        Array(log.sorted { $0.endDate > $1.endDate }.prefix(limit))
    }

    func unlockedAchievementCount(
        itemsCreated: Int,
        sessionsCompleted: Int,
        streakDays: Int
    ) -> Int {
        AchievementId.allCases.filter {
            $0.isUnlocked(
                itemsCreated: itemsCreated,
                sessionsCompleted: sessionsCompleted,
                streakDays: streakDays
            )
        }.count
    }
}
