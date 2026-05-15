import Foundation
import SwiftUI

enum ShelfSortMode: String, CaseIterable, Identifiable {
    case dateAddedNewest
    case dateAddedOldest
    case titleAZ
    case authorAZ
    case readFirst

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dateAddedNewest: return "Date added (newest)"
        case .dateAddedOldest: return "Date added (oldest)"
        case .titleAZ: return "Title A–Z"
        case .authorAZ: return "Author A–Z"
        case .readFirst: return "Read first"
        }
    }
}

enum LogSortMode: String, CaseIterable, Identifiable {
    case finishNewest
    case finishOldest
    case titleAZ
    case authorAZ
    case ratingHigh

    var id: String { rawValue }

    var title: String {
        switch self {
        case .finishNewest: return "Finish date (newest)"
        case .finishOldest: return "Finish date (oldest)"
        case .titleAZ: return "Title A–Z"
        case .authorAZ: return "Author A–Z"
        case .ratingHigh: return "Rating (high first)"
        }
    }
}

enum ReadStatusFilter: String, CaseIterable, Identifiable {
    case all
    case readOnly
    case unreadOnly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .readOnly: return "Read"
        case .unreadOnly: return "Unread"
        }
    }
}

struct ShelfBook: Codable, Identifiable, Equatable, Hashable {
    var id: UUID
    var title: String
    var author: String
    var isRead: Bool
    var genre: String
    var notes: String
    var tags: [String]
    var seriesName: String
    var seriesVolume: String
    var addedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        author: String,
        isRead: Bool = false,
        genre: String = "",
        notes: String = "",
        tags: [String] = [],
        seriesName: String = "",
        seriesVolume: String = "",
        addedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.isRead = isRead
        self.genre = genre
        self.notes = notes
        self.tags = tags
        self.seriesName = seriesName
        self.seriesVolume = seriesVolume
        self.addedAt = addedAt
    }

    enum CodingKeys: String, CodingKey {
        case id, title, author, isRead, genre, notes, tags, seriesName, seriesVolume, addedAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        author = try c.decode(String.self, forKey: .author)
        isRead = try c.decodeIfPresent(Bool.self, forKey: .isRead) ?? false
        genre = try c.decodeIfPresent(String.self, forKey: .genre) ?? ""
        notes = try c.decodeIfPresent(String.self, forKey: .notes) ?? ""
        tags = try c.decodeIfPresent([String].self, forKey: .tags) ?? []
        seriesName = try c.decodeIfPresent(String.self, forKey: .seriesName) ?? ""
        seriesVolume = try c.decodeIfPresent(String.self, forKey: .seriesVolume) ?? ""
        addedAt = try c.decodeIfPresent(Date.self, forKey: .addedAt) ?? Date()
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(title, forKey: .title)
        try c.encode(author, forKey: .author)
        try c.encode(isRead, forKey: .isRead)
        try c.encode(genre, forKey: .genre)
        try c.encode(notes, forKey: .notes)
        try c.encode(tags, forKey: .tags)
        try c.encode(seriesName, forKey: .seriesName)
        try c.encode(seriesVolume, forKey: .seriesVolume)
        try c.encode(addedAt, forKey: .addedAt)
    }
}

struct ReadingLogEntry: Codable, Identifiable, Equatable, Hashable {
    var id: UUID
    var title: String
    var author: String
    var genre: String
    var startDate: Date
    var endDate: Date
    var rating: Int
    var notes: String
    var tags: [String]
    var seriesName: String
    var seriesVolume: String
    var loggedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        author: String,
        genre: String,
        startDate: Date,
        endDate: Date,
        rating: Int,
        notes: String = "",
        tags: [String] = [],
        seriesName: String = "",
        seriesVolume: String = "",
        loggedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.genre = genre
        self.startDate = startDate
        self.endDate = endDate
        self.rating = rating
        self.notes = notes
        self.tags = tags
        self.seriesName = seriesName
        self.seriesVolume = seriesVolume
        self.loggedAt = loggedAt
    }

    enum CodingKeys: String, CodingKey {
        case id, title, author, genre, startDate, endDate, rating, notes, tags, seriesName, seriesVolume, loggedAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        author = try c.decode(String.self, forKey: .author)
        genre = try c.decodeIfPresent(String.self, forKey: .genre) ?? "General"
        startDate = try c.decode(Date.self, forKey: .startDate)
        endDate = try c.decode(Date.self, forKey: .endDate)
        rating = try c.decodeIfPresent(Int.self, forKey: .rating) ?? 3
        notes = try c.decodeIfPresent(String.self, forKey: .notes) ?? ""
        tags = try c.decodeIfPresent([String].self, forKey: .tags) ?? []
        seriesName = try c.decodeIfPresent(String.self, forKey: .seriesName) ?? ""
        seriesVolume = try c.decodeIfPresent(String.self, forKey: .seriesVolume) ?? ""
        loggedAt = try c.decodeIfPresent(Date.self, forKey: .loggedAt) ?? (try c.decode(Date.self, forKey: .endDate))
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(title, forKey: .title)
        try c.encode(author, forKey: .author)
        try c.encode(genre, forKey: .genre)
        try c.encode(startDate, forKey: .startDate)
        try c.encode(endDate, forKey: .endDate)
        try c.encode(rating, forKey: .rating)
        try c.encode(notes, forKey: .notes)
        try c.encode(tags, forKey: .tags)
        try c.encode(seriesName, forKey: .seriesName)
        try c.encode(seriesVolume, forKey: .seriesVolume)
        try c.encode(loggedAt, forKey: .loggedAt)
    }
}

struct InsightFinishedBook: Codable, Identifiable, Equatable, Hashable {
    var id: UUID
    var title: String
    var genre: String
    var finishedDate: Date
}

struct MonthData: Codable, Identifiable, Equatable, Hashable {
    var id: String { "\(year)-\(month)" }
    var year: Int
    var month: Int
    var count: Int
}

struct InAppReminder: Codable, Identifiable, Equatable, Hashable {
    var id: UUID
    var title: String
    var detail: String
    var dueDate: Date
    var linkedShelfBookId: UUID?

    init(
        id: UUID = UUID(),
        title: String,
        detail: String = "",
        dueDate: Date,
        linkedShelfBookId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.dueDate = dueDate
        self.linkedShelfBookId = linkedShelfBookId
    }
}

enum TagParsing {
    static func tags(fromCommaSeparated text: String) -> [String] {
        text.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

enum GenreStripe {
    static func stripeColor(for genre: String) -> Color {
        let trimmed = genre.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return Color.appSurface }
        let palette: [Color] = [Color.appPrimary, Color.appAccent, Color.appSurface, Color.appTextSecondary]
        let idx = abs(trimmed.hashValue) % palette.count
        return palette[idx]
    }
}

enum AchievementId: String, CaseIterable, Identifiable {
    case firstEntry = "first_entry"
    case bookshelfBuilder = "bookshelf_builder"
    case avidReader = "avid_reader"
    case powerUser = "power_user"
    case activeUser = "active_user"
    case dedicatedUser = "dedicated_user"
    case streakThree = "streak_three"
    case streakSeven = "streak_seven"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .firstEntry: return "First Entry"
        case .bookshelfBuilder: return "Bookshelf Builder"
        case .avidReader: return "Avid Reader"
        case .powerUser: return "Power User"
        case .activeUser: return "Active User"
        case .dedicatedUser: return "Dedicated User"
        case .streakThree: return "Three-Day Streak"
        case .streakSeven: return "Week-Long Habit"
        }
    }

    var detail: String {
        switch self {
        case .firstEntry: return "Added the first book to your collection."
        case .bookshelfBuilder: return "Added ten books to your collection."
        case .avidReader: return "Tracked reading twenty books."
        case .powerUser: return "Reached 50 items."
        case .activeUser: return "Completed 10 sessions."
        case .dedicatedUser: return "Completed 50 sessions."
        case .streakThree: return "Used the app 3 days in a row."
        case .streakSeven: return "Used the app 7 days in a row."
        }
    }

    func isUnlocked(itemsCreated: Int, sessionsCompleted: Int, streakDays: Int) -> Bool {
        switch self {
        case .firstEntry: return itemsCreated >= 1
        case .bookshelfBuilder: return itemsCreated >= 10
        case .avidReader: return sessionsCompleted >= 20
        case .powerUser: return itemsCreated >= 50
        case .activeUser: return sessionsCompleted >= 10
        case .dedicatedUser: return sessionsCompleted >= 50
        case .streakThree: return streakDays >= 3
        case .streakSeven: return streakDays >= 7
        }
    }
}
