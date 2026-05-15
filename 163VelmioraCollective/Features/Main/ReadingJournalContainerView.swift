import SwiftUI

struct ReadingJournalContainerView: View {
    @EnvironmentObject private var tabCoordinator: MainTabCoordinator

    var body: some View {
        VStack(spacing: 0) {
            JournalSegmentBar(selection: $tabCoordinator.journalSegment, titles: ["Reading Log", "Insights"])

            Group {
                if tabCoordinator.journalSegment == 0 {
                    Feature2ReadingLogView()
                } else {
                    Feature3InsightsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .appScreenBackdrop()
        .appNavigationRoot()
    }
}
