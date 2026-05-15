import Combine
import Foundation
import SwiftUI

enum InsightsYearScope: Int, CaseIterable, Identifiable {
    case currentYear
    case lastYear
    case allTime

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .currentYear: return "Current Year"
        case .lastYear: return "Last Year"
        case .allTime: return "All Time"
        }
    }
}

final class Feature3InsightsViewModel: ObservableObject {
    @Published var scope: InsightsYearScope = .currentYear
    @Published var genreField = ""
    @Published var genreShake: CGFloat = 0
    @Published var genreError = ""

    func filteredFinishedBooks(from store: LibraryAppStorage) -> [InsightFinishedBook] {
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        switch scope {
        case .currentYear:
            return store.finishedInsightBooks.filter { calendar.component(.year, from: $0.finishedDate) == currentYear }
        case .lastYear:
            return store.finishedInsightBooks.filter { calendar.component(.year, from: $0.finishedDate) == currentYear - 1 }
        case .allTime:
            return store.finishedInsightBooks
        }
    }

    func filteredReadingLogs(from store: LibraryAppStorage) -> [ReadingLogEntry] {
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        switch scope {
        case .currentYear:
            return store.readingLog.filter { calendar.component(.year, from: $0.endDate) == currentYear }
        case .lastYear:
            return store.readingLog.filter { calendar.component(.year, from: $0.endDate) == currentYear - 1 }
        case .allTime:
            return store.readingLog
        }
    }

    func genreCounts(from books: [InsightFinishedBook]) -> [(genre: String, count: Int)] {
        var buckets: [String: Int] = [:]
        for book in books {
            let key = book.genre.isEmpty ? "General" : book.genre
            buckets[key, default: 0] += 1
        }
        return buckets.map { ($0.key, $0.value) }.sorted { $0.count > $1.count }
    }

    func monthlyBars(from store: LibraryAppStorage) -> [MonthData] {
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        switch scope {
        case .currentYear:
            return store.monthlyCompletions.filter { $0.year == currentYear }
        case .lastYear:
            return store.monthlyCompletions.filter { $0.year == currentYear - 1 }
        case .allTime:
            return store.monthlyCompletions
        }
    }

    func topAuthors(from logs: [ReadingLogEntry], hidden: [String]) -> [(name: String, count: Int)] {
        var buckets: [String: Int] = [:]
        for log in logs {
            let name = log.author.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty else { continue }
            if hidden.contains(name) { continue }
            buckets[name, default: 0] += 1
        }
        return buckets
            .map { (name: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
            .prefix(8)
            .map { (name: $0.name, count: $0.count) }
    }

    func averageReadingDays(from logs: [ReadingLogEntry]) -> Double {
        guard !logs.isEmpty else { return 0 }
        let total = logs.reduce(0.0) { partial, entry in
            partial + entry.endDate.timeIntervalSince(entry.startDate)
        }
        let days = total / (60 * 60 * 24)
        return days / Double(logs.count)
    }

    func validateGenreField() -> Bool {
        let trimmed = genreField.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            genreError = "Enter a genre to pin."
            withAnimation(.default) { genreShake += 1 }
            FeedbackEffects.invalidInput()
            return false
        }
        genreError = ""
        return true
    }
}
