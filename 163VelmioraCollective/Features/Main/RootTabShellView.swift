import SwiftUI

struct RootTabShellView: View {
    @EnvironmentObject private var store: LibraryAppStorage
    @EnvironmentObject private var tabCoordinator: MainTabCoordinator
    @EnvironmentObject private var achievementPresenter: AchievementBannerPresenter

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Group {
                    switch tabCoordinator.selectedTab {
                    case .home:
                        HomeView()
                    case .bookshelf:
                        Feature1BookshelfView()
                    case .reading:
                        ReadingJournalContainerView()
                    case .achievements:
                        AchievementsTabView()
                    case .settings:
                        SettingsTabView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                customTabBar
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)

            AchievementTopBanner(presenter: achievementPresenter)
        }
        .background(Color.clear)
    }

    private var customTabBar: some View {
        HStack(spacing: 6) {
            ForEach(AppRootTab.allCases) { tab in
                let isSelected = tabCoordinator.selectedTab == tab
                Button {
                    FeedbackEffects.buttonTap()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                        tabCoordinator.selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.systemImage)
                            .font(.system(size: isSelected ? 21 : 19, weight: .semibold))
                        Text(tab.title)
                            .font(.caption2.weight(.bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(isSelected ? Color.appOnPrimary : Color.appTextSecondary)
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .padding(.vertical, 8)
                    .background(
                        Group {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(AppGradients.tabSelected)
                            }
                        }
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .animation(.spring(response: 0.4, dampingFraction: 0.72), value: isSelected)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .appDepthCard(cornerRadius: 24, shadow: .floating)
        .padding(.horizontal, 8)
        .padding(.bottom, 4)
        .ignoresSafeArea(edges: .bottom)
    }
}
