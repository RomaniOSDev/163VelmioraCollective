import SwiftUI

struct AchievementsTabView: View {
    @EnvironmentObject private var store: LibraryAppStorage

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    private var unlockedCount: Int {
        AchievementId.allCases.filter {
            $0.isUnlocked(
                itemsCreated: store.itemsCreated,
                sessionsCompleted: store.totalSessionsCompleted,
                streakDays: store.streakDays
            )
        }.count
    }

    var body: some View {
        AppNavigationScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    summaryCard

                    HStack {
                        AppSectionHeader(
                            title: "Achievements",
                            subtitle: "\(unlockedCount) of \(AchievementId.allCases.count) unlocked",
                            systemImage: "rosette"
                        )
                    }

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(AchievementId.allCases) { achievement in
                            AchievementBadgeCell(
                                achievement: achievement,
                                unlocked: achievement.isUnlocked(
                                    itemsCreated: store.itemsCreated,
                                    sessionsCompleted: store.totalSessionsCompleted,
                                    streakDays: store.streakDays
                                )
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.inline)
            .appToolbarChrome()
        }
    }

    private var summaryCard: some View {
        AppSurfaceCard(accentBorder: unlockedCount == AchievementId.allCases.count) {
            VStack(alignment: .leading, spacing: 12) {
                AppSectionHeader(title: "Your snapshot", systemImage: "sparkles")

                HStack(spacing: 10) {
                    AppStatPill(title: "Streak", value: "\(store.streakDays)d", tint: .appAccent)
                    AppStatPill(title: "Sessions", value: "\(store.totalSessionsCompleted)")
                }

                AppMetricRow(label: "Items created", value: "\(store.itemsCreated)", icon: "plus.circle.fill")
                AppMetricRow(label: "Minutes in app", value: "\(store.totalMinutesUsed)", icon: "clock.fill")
                AppMetricRow(label: "Books on shelf", value: "\(store.shelfBooks.count)", icon: "books.vertical.fill")
                AppMetricRow(label: "Journal entries", value: "\(store.readingLog.count)", icon: "book.pages.fill")

                ProgressView(value: Double(unlockedCount), total: Double(AchievementId.allCases.count))
                    .tint(Color.appPrimary)
                Text("Badge progress")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }
}
