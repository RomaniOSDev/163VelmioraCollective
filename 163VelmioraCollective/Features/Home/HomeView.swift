import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: LibraryAppStorage
    @EnvironmentObject private var tabCoordinator: MainTabCoordinator
    @StateObject private var viewModel = HomeViewModel()

    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    private var goalYear: Int {
        store.readingGoalYear == 0 ? currentYear : store.readingGoalYear
    }

    private var goalFinished: Int {
        store.booksFinishedCount(in: goalYear)
    }

    private var goalTarget: Int {
        store.readingGoalTarget
    }

    private var goalProgress: Double {
        viewModel.goalProgress(finished: goalFinished, target: goalTarget)
    }

    private var unreadCount: Int {
        store.shelfBooks.filter { !$0.isRead }.count
    }

    private var heroSubtitle: String {
        if store.shelfBooks.isEmpty && store.readingLog.isEmpty {
            return "Your reading hub — add a book to get started."
        }
        if unreadCount > 0 {
            return "\(unreadCount) book\(unreadCount == 1 ? "" : "s") waiting on your shelf."
        }
        if goalTarget > 0, goalFinished < goalTarget {
            return "\(goalTarget - goalFinished) more to hit your \(goalYear) goal."
        }
        return "Keep your streak alive — log today's reading."
    }

    private var dueReminders: [InAppReminder] {
        store.dueAndOverdueReminders()
    }

    var body: some View {
        AppNavigationScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HomeHeroBanner(
                        greeting: viewModel.greeting(),
                        streakDays: store.streakDays,
                        subtitle: heroSubtitle
                    )

                    statsGrid

                    HomeGoalWidget(
                        year: goalYear,
                        finished: goalFinished,
                        target: goalTarget,
                        progress: goalProgress,
                        action: openInsights
                    )

                    quickActionsSection

                    if !viewModel.recentShelfBooks(from: store.shelfBooks).isEmpty {
                        continueReadingSection
                    }

                    if !viewModel.recentLogEntries(from: store.readingLog).isEmpty {
                        recentLogSection
                    }

                    HomeRemindersWidget(
                        reminders: dueReminders.isEmpty ? Array(store.inAppReminders.prefix(3)) : dueReminders,
                        onOpenSettings: openSettings
                    )

                    badgesTeaser
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .padding(.bottom, 8)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .appToolbarChrome()
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            HomeStatWidget(
                title: "On shelf",
                value: "\(store.shelfBooks.count)",
                imageName: "WidgetShelf",
                tint: .appPrimary,
                action: openBookshelf
            )
            HomeStatWidget(
                title: "Journal",
                value: "\(store.readingLog.count)",
                imageName: "WidgetJournal",
                tint: .appAccent,
                action: openJournal
            )
            HomeStatWidget(
                title: "Unread",
                value: "\(unreadCount)",
                imageName: "WidgetShelf",
                tint: .appTextSecondary,
                action: openBookshelf
            )
            HomeStatWidget(
                title: "Badges",
                value: "\(viewModel.unlockedAchievementCount(itemsCreated: store.itemsCreated, sessionsCompleted: store.totalSessionsCompleted, streakDays: store.streakDays))",
                imageName: "WidgetGoal",
                tint: .appAccent,
                action: openAchievements
            )
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            AppSectionHeader(title: "Quick actions", systemImage: "bolt.fill")
            HomeQuickActionsGrid(actions: [
                HomeQuickAction(
                    title: "Add book",
                    subtitle: "Expand your shelf",
                    imageName: "WidgetShelf",
                    systemImage: "plus",
                    action: openBookshelf
                ),
                HomeQuickAction(
                    title: "Log reading",
                    subtitle: "New journal entry",
                    imageName: "WidgetJournal",
                    systemImage: "square.and.pencil",
                    action: openJournal
                ),
                HomeQuickAction(
                    title: "Insights",
                    subtitle: "Charts & goals",
                    imageName: "WidgetGoal",
                    systemImage: "chart.pie",
                    action: openInsights
                ),
                HomeQuickAction(
                    title: "Settings",
                    subtitle: "Reminders & data",
                    imageName: "HomeHero",
                    systemImage: "gearshape",
                    action: openSettings
                )
            ])
        }
    }

    private var continueReadingSection: some View {
        AppSurfaceCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    AppSectionHeader(title: "On your shelf", subtitle: "Tap to open", systemImage: "books.vertical")
                    Spacer()
                    Button("See all", action: openBookshelf)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appPrimary)
                }
                ForEach(viewModel.recentShelfBooks(from: store.shelfBooks)) { book in
                    HomeBookMiniCard(book: book, action: openBookshelf)
                }
            }
        }
    }

    private var recentLogSection: some View {
        AppSurfaceCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    AppSectionHeader(title: "Recently finished", systemImage: "book.pages")
                    Spacer()
                    Button("Journal", action: openJournal)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appPrimary)
                }
                ForEach(viewModel.recentLogEntries(from: store.readingLog)) { entry in
                    HomeLogMiniCard(entry: entry, action: openJournal)
                }
            }
        }
    }

    private var badgesTeaser: some View {
        Button(action: openAchievements) {
            HStack(spacing: 14) {
                Image("WidgetGoal")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Your progress")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("\(store.totalSessionsCompleted) sessions · \(store.totalMinutesUsed) min in app")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.appTextSecondary)
            }
            .padding(14)
            .appDepthCard(cornerRadius: 18, highlighted: true, shadow: .card)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func openBookshelf() {
        FeedbackEffects.buttonTap()
        tabCoordinator.openBookshelf()
    }

    private func openJournal() {
        FeedbackEffects.buttonTap()
        tabCoordinator.openJournal()
    }

    private func openInsights() {
        FeedbackEffects.buttonTap()
        tabCoordinator.openInsights()
    }

    private func openAchievements() {
        FeedbackEffects.buttonTap()
        tabCoordinator.openAchievements()
    }

    private func openSettings() {
        FeedbackEffects.buttonTap()
        tabCoordinator.openSettings()
    }
}
