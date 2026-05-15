import Combine
import SwiftUI

struct AchievementTopBanner: View {
    @ObservedObject var presenter: AchievementBannerPresenter

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            bannerCard
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private var bannerCard: some View {
        if let title = presenter.visibleTitle {
            HStack(spacing: 12) {
                Image(systemName: "rosette")
                    .foregroundStyle(SwiftUI.Color.appPrimary)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Achievement Unlocked")
                        .font(Font.caption.weight(.semibold))
                        .foregroundStyle(SwiftUI.Color.appTextSecondary)
                    Text(title)
                        .font(Font.headline.weight(.bold))
                        .foregroundStyle(SwiftUI.Color.appTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Spacer(minLength: 0)
            }
            .padding(16)
            .appDepthCard(cornerRadius: 16, accentBorder: true, shadow: .elevated)
            .padding(.horizontal, 16)
            .offset(y: presenter.isShowing ? 0 : -160)
            .opacity(presenter.isShowing ? 1.0 : 0.0)
            .accessibilityElement(children: .combine)
        }
    }

}
