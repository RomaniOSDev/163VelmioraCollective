import SwiftUI

private struct OnboardingPage: Identifiable {
    let id: Int
    let title: String
    let message: String
    let imageName: String
    let systemImage: String
    let highlights: [String]
}

struct OnboardingView: View {
    @EnvironmentObject private var store: LibraryAppStorage

    @State private var pageIndex = 0
    @State private var contentAppeared = false

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            title: "Your reading home",
            message: "Everything in one place: shelf, journal, goals, and progress — with a calm dashboard to start each session.",
            imageName: "HomeHero",
            systemImage: "house.fill",
            highlights: ["Personalized Home screen", "Quick actions & stats", "Reading streak at a glance"]
        ),
        OnboardingPage(
            id: 1,
            title: "Build your shelf",
            message: "Add books with genres, tags, series, and notes. Search, filter, and sort your library the way you like.",
            imageName: "WidgetShelf",
            systemImage: "books.vertical.fill",
            highlights: ["Custom cover previews", "Tags & series volumes", "Read / unread status"]
        ),
        OnboardingPage(
            id: 2,
            title: "Log every finish",
            message: "Record dates, ratings, and reflections. Your journal powers insights and yearly reading goals.",
            imageName: "WidgetJournal",
            systemImage: "book.pages.fill",
            highlights: ["Reading log with stars", "Genre & author charts", "Yearly goal tracker"]
        ),
        OnboardingPage(
            id: 3,
            title: "Grow your habit",
            message: "Earn badges, track reminders inside the app, and keep your streak alive — no push permissions needed.",
            imageName: "WidgetGoal",
            systemImage: "rosette",
            highlights: ["Achievements & badges", "In-app reminders", "Insights & summaries"]
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            TabView(selection: $pageIndex) {
                ForEach(pages) { page in
                    onboardingPage(page)
                        .tag(page.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.28), value: pageIndex)

            footerControls
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
                contentAppeared = true
            }
        }
        .onChange(of: pageIndex) { _ in
            FeedbackEffects.buttonTap()
            contentAppeared = false
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8).delay(0.05)) {
                contentAppeared = true
            }
        }
    }

    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Book Explorer")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                Text("Step \(pageIndex + 1) of \(pages.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
            }
            Spacer()
            if pageIndex < pages.count - 1 {
                Button("Skip") {
                    finishOnboarding()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appAccent)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var footerControls: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                ForEach(pages) { page in
                    Capsule()
                        .fill(page.id == pageIndex ? Color.appPrimary : Color.appTextSecondary.opacity(0.3))
                        .frame(width: page.id == pageIndex ? 28 : 8, height: 8)
                        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: pageIndex)
                }
            }

            Button(action: advance) {
                HStack(spacing: 8) {
                    Text(pageIndex == pages.count - 1 ? "Get Started" : "Continue")
                    Image(systemName: pageIndex == pages.count - 1 ? "arrow.right.circle.fill" : "chevron.right")
                }
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            }
            .buttonStyle(PrimaryProminentButtonStyle())
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 28)
        .padding(.top, 8)
    }

    @ViewBuilder
    private func onboardingPage(_ page: OnboardingPage) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroVisual(page: page)
                    .opacity(contentAppeared ? 1 : 0)
                    .offset(y: contentAppeared ? 0 : 16)

                AppSurfaceCard(elevated: true) {
                    VStack(alignment: .leading, spacing: 14) {
                        AppSectionHeader(
                            title: page.title,
                            subtitle: "Built for calm reading",
                            systemImage: page.systemImage
                        )

                        Text(page.message)
                            .font(.body)
                            .foregroundStyle(Color.appTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(page.highlights, id: \.self) { highlight in
                                highlightRow(highlight)
                            }
                        }
                    }
                }
                .opacity(contentAppeared ? 1 : 0)
                .offset(y: contentAppeared ? 0 : 20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
    }

    private func heroVisual(page: OnboardingPage) -> some View {
        ZStack(alignment: .bottomLeading) {
            Image(page.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .clipped()

            AppGradients.heroScrim

            HStack {
                Image(systemName: page.systemImage)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.appPrimary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.appSurface.opacity(0.92))
                    )
                Spacer()
            }
            .padding(16)
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppGradients.borderAccent, lineWidth: 1)
        )
        .compositingGroup()
        .appDepthShadow(.elevated)
    }

    private func highlightRow(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appAccent)
            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.appTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .appDepthInset(cornerRadius: 12)
    }

    private func advance() {
        FeedbackEffects.buttonTap()
        if pageIndex < pages.count - 1 {
            withAnimation(.easeInOut(duration: 0.28)) {
                pageIndex += 1
            }
        } else {
            finishOnboarding()
        }
    }

    private func finishOnboarding() {
        FeedbackEffects.saveOrComplete()
        withAnimation(.easeInOut(duration: 0.3)) {
            store.markOnboardingFinished()
        }
    }
}
