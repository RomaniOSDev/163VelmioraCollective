import Combine
import SwiftUI

struct ContentView: View {
    @StateObject private var store = LibraryAppStorage()
    @StateObject private var tabCoordinator = MainTabCoordinator()
    @StateObject private var achievementPresenter = AchievementBannerPresenter()
    @Environment(\.scenePhase) private var scenePhase
    @State private var foregroundSessionStart: Date?
    @State private var reminderBannerDismissed = false

    private var dueReminders: [InAppReminder] {
        store.dueAndOverdueReminders()
    }

    var body: some View {
        ZStack(alignment: .top) {
            AppScreenBackdrop()

            Group {
                if store.hasSeenOnboarding {
                    RootTabShellView()
                        .environmentObject(store)
                        .environmentObject(tabCoordinator)
                        .environmentObject(achievementPresenter)
                } else {
                    OnboardingView()
                        .environmentObject(store)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
            .preferredColorScheme(.dark)
            .onAppear {
                store.achievementPresenter = achievementPresenter
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    foregroundSessionStart = Date()
                } else if newPhase == .background {
                    reminderBannerDismissed = false
                    if let start = foregroundSessionStart {
                        let seconds = Int(Date().timeIntervalSince(start))
                        store.addForegroundUsageSeconds(seconds)
                    }
                    foregroundSessionStart = nil
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .dataReset)) { _ in
                store.loadFromDefaults()
                tabCoordinator.selectedTab = .home
            }

            if store.hasSeenOnboarding, !dueReminders.isEmpty, !reminderBannerDismissed {
                ReminderBannerStrip(reminders: dueReminders) {
                    FeedbackEffects.buttonTap()
                    reminderBannerDismissed = true
                }
                .padding(.top, 6)
                .zIndex(10)
            }
        }
    }
}

private struct ReminderBannerStrip: View {
    let reminders: [InAppReminder]
    var onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.appPrimary.opacity(0.2))
                        .frame(width: 32, height: 32)
                    Image(systemName: "bell.badge.fill")
                        .foregroundStyle(Color.appPrimary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Reminders due")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("No push — only inside the app")
                        .font(.caption2)
                        .foregroundStyle(Color.appTextSecondary)
                }
                Spacer()
                Button("Dismiss", action: onDismiss)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appAccent)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(reminders) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.appTextPrimary)
                                .lineLimit(2)
                            Text(item.dueDate, style: .date)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(Color.appAccent)
                        }
                        .padding(12)
                        .frame(width: 190, alignment: .leading)
                        .appDepthCard(cornerRadius: 14, shadow: .soft)
                    }
                }
            }
        }
        .padding(14)
        .appDepthCard(cornerRadius: 20, accentBorder: true, shadow: .elevated)
        .padding(.horizontal, 12)
    }
}

#Preview {
    ContentView()
}
