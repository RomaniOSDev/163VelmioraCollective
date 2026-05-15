import Combine
import Foundation
import SwiftUI

final class AchievementBannerPresenter: ObservableObject {
    @Published private(set) var visibleTitle: String?
    @Published private(set) var isShowing: Bool = false

    private var queue: [String] = []
    private var processing = false

    func enqueue(_ title: String) {
        queue.append(title)
        showNextIfNeeded()
    }

    private func showNextIfNeeded() {
        guard !processing else { return }
        guard let next = queue.first else { return }
        processing = true
        queue.removeFirst()
        visibleTitle = next
        withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
            isShowing = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self else { return }
            withAnimation(.easeInOut(duration: 0.3)) {
                self.isShowing = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.visibleTitle = nil
                self.processing = false
                self.showNextIfNeeded()
            }
        }
    }
}

final class LibraryAppStorage: ObservableObject {
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    @Published private(set) var hasSeenOnboarding: Bool = false
    @Published private(set) var shelfBooks: [ShelfBook] = []
    @Published private(set) var readingLog: [ReadingLogEntry] = []
    @Published private(set) var finishedInsightBooks: [InsightFinishedBook] = []
    @Published private(set) var favoriteGenres: [String] = []
    @Published private(set) var monthlyCompletions: [MonthData] = []
    @Published private(set) var totalSessionsCompleted: Int = 0
    @Published private(set) var totalMinutesUsed: Int = 0
    @Published private(set) var streakDays: Int = 0
    @Published private(set) var itemsCreated: Int = 0
    @Published private(set) var achievementsUnlocked: [String: Date] = [:]
    @Published private(set) var lastOpenedBookshelfDate: Date?
    @Published private(set) var totalBooksReadCount: Int = 0
    @Published private(set) var hiddenAuthors: [String] = []
    @Published private(set) var readingGoalYear: Int = 0
    @Published private(set) var readingGoalTarget: Int = 0
    @Published private(set) var inAppReminders: [InAppReminder] = []
    @Published var lastAddedShelfBookId: UUID?
    @Published var lastPulsingLogEntryId: UUID?

    weak var achievementPresenter: AchievementBannerPresenter?

    private var lastMeaningfulDayStart: TimeInterval = 0

    private enum Keys: String, CaseIterable {
        case hasSeenOnboarding
        case shelfBooks
        case readingLog
        case finishedInsightBooks
        case favoriteGenres
        case monthlyCompletions
        case totalSessionsCompleted
        case totalMinutesUsed
        case streakDays
        case itemsCreated
        case achievementsUnlocked
        case lastOpenedBookshelfDate
        case totalBooksReadCount
        case hiddenAuthors
        case lastMeaningfulDayStart
        case readingGoalYear
        case readingGoalTarget
        case inAppReminders
    }

    private func prefixed(_ key: Keys) -> String {
        "bn_\(key.rawValue)"
    }

    init() {
        loadFromDefaults()
    }

    func loadFromDefaults() {
        hasSeenOnboarding = defaults.bool(forKey: prefixed(.hasSeenOnboarding))
        shelfBooks = decode([ShelfBook].self, from: prefixed(.shelfBooks)) ?? []
        readingLog = decode([ReadingLogEntry].self, from: prefixed(.readingLog)) ?? []
        finishedInsightBooks = decode([InsightFinishedBook].self, from: prefixed(.finishedInsightBooks)) ?? []
        favoriteGenres = decode([String].self, from: prefixed(.favoriteGenres)) ?? []
        monthlyCompletions = decode([MonthData].self, from: prefixed(.monthlyCompletions)) ?? []
        totalSessionsCompleted = defaults.integer(forKey: prefixed(.totalSessionsCompleted))
        totalMinutesUsed = defaults.integer(forKey: prefixed(.totalMinutesUsed))
        streakDays = defaults.integer(forKey: prefixed(.streakDays))
        itemsCreated = defaults.integer(forKey: prefixed(.itemsCreated))
        achievementsUnlocked = decode([String: Date].self, from: prefixed(.achievementsUnlocked)) ?? [:]
        if let interval = defaults.object(forKey: prefixed(.lastOpenedBookshelfDate)) as? TimeInterval, interval > 0 {
            lastOpenedBookshelfDate = Date(timeIntervalSince1970: interval)
        } else {
            lastOpenedBookshelfDate = nil
        }
        totalBooksReadCount = defaults.integer(forKey: prefixed(.totalBooksReadCount))
        hiddenAuthors = decode([String].self, from: prefixed(.hiddenAuthors)) ?? []
        lastMeaningfulDayStart = defaults.double(forKey: prefixed(.lastMeaningfulDayStart))
        readingGoalYear = defaults.integer(forKey: prefixed(.readingGoalYear))
        readingGoalTarget = defaults.integer(forKey: prefixed(.readingGoalTarget))
        inAppReminders = decode([InAppReminder].self, from: prefixed(.inAppReminders)) ?? []
        evaluateAchievements(notify: false)
    }

    func markOnboardingFinished() {
        hasSeenOnboarding = true
        defaults.set(true, forKey: prefixed(.hasSeenOnboarding))
        registerMeaningfulActivity()
    }

    func touchBookshelfOpened() {
        lastOpenedBookshelfDate = Date()
        defaults.set(Date().timeIntervalSince1970, forKey: prefixed(.lastOpenedBookshelfDate))
        registerMeaningfulActivity()
    }

    func addForegroundUsageSeconds(_ seconds: Int) {
        guard seconds > 0 else { return }
        let minutes = seconds / 60
        guard minutes > 0 else { return }
        totalMinutesUsed += minutes
        defaults.set(totalMinutesUsed, forKey: prefixed(.totalMinutesUsed))
    }

    func registerMeaningfulActivity() {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date()).timeIntervalSince1970

        if lastMeaningfulDayStart <= 0 {
            streakDays = max(streakDays, 1)
        } else {
            let lastDate = Date(timeIntervalSince1970: lastMeaningfulDayStart)
            let lastDay = calendar.startOfDay(for: lastDate)
            let today = calendar.startOfDay(for: Date())
            let dayDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if dayDiff == 0 {
                streakDays = max(streakDays, 1)
            } else if dayDiff == 1 {
                streakDays += 1
            } else {
                streakDays = 1
            }
        }

        lastMeaningfulDayStart = todayStart
        defaults.set(lastMeaningfulDayStart, forKey: prefixed(.lastMeaningfulDayStart))
        defaults.set(streakDays, forKey: prefixed(.streakDays))
        evaluateAchievements(notify: true)
    }

    func addShelfBook(_ book: ShelfBook) -> Bool {
        let trimmedTitle = book.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAuthor = book.author.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty, !trimmedAuthor.isEmpty else { return false }

        var newBook = book
        newBook.title = trimmedTitle
        newBook.author = trimmedAuthor
        newBook.addedAt = Date()
        shelfBooks.insert(newBook, at: 0)
        itemsCreated += 1
        if newBook.isRead {
            totalBooksReadCount += 1
        }
        encode(shelfBooks, to: prefixed(.shelfBooks))
        defaults.set(itemsCreated, forKey: prefixed(.itemsCreated))
        defaults.set(totalBooksReadCount, forKey: prefixed(.totalBooksReadCount))
        lastAddedShelfBookId = newBook.id
        registerMeaningfulActivity()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.lastAddedShelfBookId = nil
        }
        return true
    }

    func updateShelfBook(_ book: ShelfBook) {
        guard let index = shelfBooks.firstIndex(where: { $0.id == book.id }) else { return }
        let old = shelfBooks[index]
        shelfBooks[index] = book
        if old.isRead != book.isRead {
            if book.isRead {
                totalBooksReadCount += 1
            } else {
                totalBooksReadCount = max(0, totalBooksReadCount - 1)
            }
            defaults.set(totalBooksReadCount, forKey: prefixed(.totalBooksReadCount))
        }
        encode(shelfBooks, to: prefixed(.shelfBooks))
        registerMeaningfulActivity()
    }

    func deleteShelfBook(id: UUID) {
        if let book = shelfBooks.first(where: { $0.id == id }) {
            if book.isRead {
                totalBooksReadCount = max(0, totalBooksReadCount - 1)
                defaults.set(totalBooksReadCount, forKey: prefixed(.totalBooksReadCount))
            }
        }
        shelfBooks.removeAll { $0.id == id }
        encode(shelfBooks, to: prefixed(.shelfBooks))
        registerMeaningfulActivity()
    }

    func addReadingLogEntry(_ entry: ReadingLogEntry) -> Bool {
        let trimmedTitle = entry.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAuthor = entry.author.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty, !trimmedAuthor.isEmpty else { return false }
        let trimmedGenre = entry.genre.trimmingCharacters(in: .whitespacesAndNewlines)
        let safeGenre = trimmedGenre.isEmpty ? "General" : trimmedGenre

        var newEntry = entry
        newEntry.title = trimmedTitle
        newEntry.author = trimmedAuthor
        newEntry.genre = safeGenre
        newEntry.loggedAt = Date()

        readingLog.insert(newEntry, at: 0)
        encode(readingLog, to: prefixed(.readingLog))

        let insight = InsightFinishedBook(id: newEntry.id, title: newEntry.title, genre: safeGenre, finishedDate: newEntry.endDate)
        finishedInsightBooks.insert(insight, at: 0)
        encode(finishedInsightBooks, to: prefixed(.finishedInsightBooks))

        mergeMonthlyCompletion(year: calendarYear(for: newEntry.endDate), month: calendarMonth(for: newEntry.endDate))
        totalSessionsCompleted += 1
        defaults.set(totalSessionsCompleted, forKey: prefixed(.totalSessionsCompleted))

        lastPulsingLogEntryId = newEntry.id
        registerMeaningfulActivity()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.lastPulsingLogEntryId = nil
        }
        return true
    }

    func updateReadingLogEntry(_ entry: ReadingLogEntry) {
        guard let index = readingLog.firstIndex(where: { $0.id == entry.id }) else { return }
        let previousLoggedAt = readingLog[index].loggedAt
        var updated = entry
        updated.loggedAt = previousLoggedAt
        readingLog[index] = updated
        encode(readingLog, to: prefixed(.readingLog))
        if let insightIndex = finishedInsightBooks.firstIndex(where: { $0.id == entry.id }) {
            finishedInsightBooks[insightIndex] = InsightFinishedBook(
                id: entry.id,
                title: entry.title,
                genre: entry.genre,
                finishedDate: entry.endDate
            )
            encode(finishedInsightBooks, to: prefixed(.finishedInsightBooks))
        }
        rebuildMonthlyCompletionsFromLog()
        registerMeaningfulActivity()
    }

    func deleteReadingLogEntry(id: UUID) {
        readingLog.removeAll { $0.id == id }
        encode(readingLog, to: prefixed(.readingLog))
        finishedInsightBooks.removeAll { $0.id == id }
        encode(finishedInsightBooks, to: prefixed(.finishedInsightBooks))
        totalSessionsCompleted = max(0, totalSessionsCompleted - 1)
        defaults.set(totalSessionsCompleted, forKey: prefixed(.totalSessionsCompleted))
        rebuildMonthlyCompletionsFromLog()
        registerMeaningfulActivity()
    }

    func addFavoriteGenre(_ genre: String) {
        let trimmed = genre.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard !favoriteGenres.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) else { return }
        favoriteGenres.append(trimmed)
        encode(favoriteGenres, to: prefixed(.favoriteGenres))
        registerMeaningfulActivity()
    }

    func removeFavoriteGenre(_ genre: String) {
        favoriteGenres.removeAll { $0 == genre }
        encode(favoriteGenres, to: prefixed(.favoriteGenres))
        registerMeaningfulActivity()
    }

    func hideAuthor(_ name: String) {
        guard !hiddenAuthors.contains(name) else { return }
        hiddenAuthors.append(name)
        encode(hiddenAuthors, to: prefixed(.hiddenAuthors))
        registerMeaningfulActivity()
    }

    func setReadingGoal(year: Int, target: Int) {
        readingGoalYear = year
        readingGoalTarget = max(0, target)
        defaults.set(readingGoalYear, forKey: prefixed(.readingGoalYear))
        defaults.set(readingGoalTarget, forKey: prefixed(.readingGoalTarget))
    }

    func booksFinishedCount(in year: Int) -> Int {
        readingLog.filter { calendarYear(for: $0.endDate) == year }.count
    }

    func saveReminders(_ items: [InAppReminder]) {
        inAppReminders = items
        encode(inAppReminders, to: prefixed(.inAppReminders))
        registerMeaningfulActivity()
    }

    func upsertReminder(_ reminder: InAppReminder) {
        var items = inAppReminders
        if let index = items.firstIndex(where: { $0.id == reminder.id }) {
            items[index] = reminder
        } else {
            items.insert(reminder, at: 0)
        }
        saveReminders(items)
    }

    func deleteReminder(id: UUID) {
        inAppReminders.removeAll { $0.id == id }
        encode(inAppReminders, to: prefixed(.inAppReminders))
        registerMeaningfulActivity()
    }

    func dueAndOverdueReminders(on date: Date = Date()) -> [InAppReminder] {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        return inAppReminders
            .filter { calendar.startOfDay(for: $0.dueDate) <= dayStart }
            .sorted { $0.dueDate < $1.dueDate }
    }

    func resetAllData() {
        Keys.allCases.forEach { defaults.removeObject(forKey: prefixed($0)) }
        hasSeenOnboarding = false
        shelfBooks = []
        readingLog = []
        finishedInsightBooks = []
        favoriteGenres = []
        monthlyCompletions = []
        totalSessionsCompleted = 0
        totalMinutesUsed = 0
        streakDays = 0
        itemsCreated = 0
        achievementsUnlocked = [:]
        lastOpenedBookshelfDate = nil
        totalBooksReadCount = 0
        hiddenAuthors = []
        readingGoalYear = 0
        readingGoalTarget = 0
        inAppReminders = []
        lastMeaningfulDayStart = 0
        lastAddedShelfBookId = nil
        lastPulsingLogEntryId = nil
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    private func evaluateAchievements(notify: Bool) {
        let now = Date()
        var changed = false
        for achievement in AchievementId.allCases {
            let meets = achievement.isUnlocked(
                itemsCreated: itemsCreated,
                sessionsCompleted: totalSessionsCompleted,
                streakDays: streakDays
            )
            if meets {
                if achievementsUnlocked[achievement.rawValue] == nil {
                    achievementsUnlocked[achievement.rawValue] = now
                    changed = true
                    if notify {
                        FeedbackEffects.achievementUnlocked()
                        achievementPresenter?.enqueue(achievement.title)
                    }
                }
            } else if achievementsUnlocked.removeValue(forKey: achievement.rawValue) != nil {
                changed = true
            }
        }
        if changed {
            encode(achievementsUnlocked, to: prefixed(.achievementsUnlocked))
        }
    }

    private func calendarYear(for date: Date) -> Int {
        Calendar.current.component(.year, from: date)
    }

    private func calendarMonth(for date: Date) -> Int {
        Calendar.current.component(.month, from: date)
    }

    private func mergeMonthlyCompletion(year: Int, month: Int) {
        if let index = monthlyCompletions.firstIndex(where: { $0.year == year && $0.month == month }) {
            monthlyCompletions[index].count += 1
        } else {
            monthlyCompletions.append(MonthData(year: year, month: month, count: 1))
        }
        encode(monthlyCompletions, to: prefixed(.monthlyCompletions))
    }

    private func rebuildMonthlyCompletionsFromLog() {
        var buckets: [String: MonthData] = [:]
        for entry in readingLog {
            let year = calendarYear(for: entry.endDate)
            let month = calendarMonth(for: entry.endDate)
            let key = "\(year)-\(month)"
            if var existing = buckets[key] {
                existing.count += 1
                buckets[key] = existing
            } else {
                buckets[key] = MonthData(year: year, month: month, count: 1)
            }
        }
        monthlyCompletions = buckets.values.sorted {
            if $0.year == $1.year {
                return $0.month < $1.month
            }
            return $0.year < $1.year
        }
        encode(monthlyCompletions, to: prefixed(.monthlyCompletions))
    }

    private func encode<T: Encodable>(_ value: T, to key: String) {
        if let data = try? encoder.encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, from key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }
}
