import SwiftUI

struct Feature3InsightsView: View {
    @EnvironmentObject private var store: LibraryAppStorage
    @EnvironmentObject private var tabCoordinator: MainTabCoordinator
    @StateObject private var viewModel = Feature3InsightsViewModel()
    @State private var chartAnimation: CGFloat = 0
    @State private var goalYear: Int = Calendar.current.component(.year, from: Date())
    @State private var goalTarget: Int = 0

    var body: some View {
        AppNavigationScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    scopePicker

                    ReadingGoalCard(
                        goalYear: $goalYear,
                        goalTarget: $goalTarget,
                        finished: store.booksFinishedCount(in: goalYear)
                    )

                    if store.readingLog.isEmpty {
                        emptyChartsContent
                    } else {
                        chartsContent
                        summaryCard
                        pinGenreSection
                        favoriteGenresSection
                        authorsSection
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
            .appToolbarChrome()
            .onChange(of: store.finishedInsightBooks.count) { _ in
                withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                    chartAnimation += 1
                }
            }
            .onAppear { syncGoalFromStore() }
            .onChange(of: goalYear) { _ in persistGoal() }
            .onChange(of: goalTarget) { _ in persistGoal() }
        }
    }

    private var scopePicker: some View {
        Picker("Scope", selection: $viewModel.scope) {
            ForEach(InsightsYearScope.allCases) { scope in
                Text(scope.title).tag(scope)
            }
        }
        .pickerStyle(.segmented)
        .tint(Color.appPrimary)
        .onChange(of: viewModel.scope) { _ in
            FeedbackEffects.buttonTap()
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                chartAnimation += 1
            }
        }
    }

    private func syncGoalFromStore() {
        let current = Calendar.current.component(.year, from: Date())
        goalYear = store.readingGoalYear == 0 ? current : store.readingGoalYear
        goalTarget = store.readingGoalTarget
    }

    private func persistGoal() {
        store.setReadingGoal(year: goalYear, target: goalTarget)
    }

    private var filteredBooks: [InsightFinishedBook] {
        viewModel.filteredFinishedBooks(from: store)
    }

    private var filteredLogs: [ReadingLogEntry] {
        viewModel.filteredReadingLogs(from: store)
    }

    private var emptyChartsContent: some View {
        AppSurfaceCard {
            VStack(spacing: 16) {
                GenrePieChart(segments: [], animated: chartAnimation)
                    .frame(height: 200)
                    .opacity(0.35)
                MonthBarChart(months: [], animated: chartAnimation)
                    .frame(height: 160)
                    .opacity(0.35)
                AppEmptyState(
                    systemImage: "chart.pie.fill",
                    title: "No data yet",
                    message: "Log your first finished book to unlock charts and trends.",
                    actionTitle: "Go to bookshelf",
                    action: addFirstBookTapped
                )
            }
        }
    }

    private var chartsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            AppSurfaceCard {
                VStack(alignment: .leading, spacing: 12) {
                    AppSectionHeader(title: "Genre mix", systemImage: "chart.pie.fill")
                    if viewModel.genreCounts(from: filteredBooks).isEmpty {
                        Text("No completions in this range yet.")
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                        GenrePieChart(segments: [], animated: chartAnimation)
                            .frame(height: 200)
                            .opacity(0.35)
                    } else {
                        GenrePieChart(segments: viewModel.genreCounts(from: filteredBooks), animated: chartAnimation)
                            .frame(height: 220)
                    }
                }
            }

            AppSurfaceCard {
                VStack(alignment: .leading, spacing: 12) {
                    AppSectionHeader(title: "Monthly completions", systemImage: "chart.bar.fill")
                    MonthBarChart(months: viewModel.monthlyBars(from: store), animated: chartAnimation)
                        .frame(height: 200)
                }
            }

            AppSurfaceCard {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Average reading span")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.appTextSecondary)
                        Text(String(format: "%.1f days", viewModel.averageReadingDays(from: filteredLogs)))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.appTextPrimary)
                    }
                    Spacer()
                    Image(systemName: "hourglass")
                        .font(.largeTitle)
                        .foregroundStyle(Color.appAccent.opacity(0.8))
                }
            }
        }
    }

    private var summaryCard: some View {
        InsightsSummaryCard(
            booksFinished: filteredBooks.count,
            topGenre: viewModel.genreCounts(from: filteredBooks).first?.genre ?? "—",
            topAuthor: viewModel.topAuthors(from: filteredLogs, hidden: store.hiddenAuthors).first?.name ?? "—",
            averageDays: viewModel.averageReadingDays(from: filteredLogs)
        )
    }

    private var pinGenreSection: some View {
        AppSurfaceCard {
            VStack(alignment: .leading, spacing: 12) {
                AppSectionHeader(title: "Pin a genre", subtitle: "Quick access in insights", systemImage: "pin.fill")
                AppFormTextField(placeholder: "Add genre to pin", text: $viewModel.genreField)
                    .shake(trigger: viewModel.genreShake)
                if !viewModel.genreError.isEmpty {
                    AppFormErrorText(message: viewModel.genreError)
                }
                Button(action: pinGenreTapped) {
                    Text("Pin genre")
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .buttonStyle(PrimaryProminentButtonStyle())
            }
        }
    }

    private var favoriteGenresSection: some View {
        Group {
            if !store.favoriteGenres.isEmpty {
                AppSurfaceCard {
                    VStack(alignment: .leading, spacing: 4) {
                        AppSectionHeader(title: "Favorite genres", systemImage: "heart.fill")
                        ForEach(store.favoriteGenres, id: \.self) { genre in
                            GenrePinCell(genre: genre)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        FeedbackEffects.buttonTap()
                                        store.removeFavoriteGenre(genre)
                                    } label: {
                                        Label("Unpin", systemImage: "pin.slash")
                                    }
                                }
                            if genre != store.favoriteGenres.last {
                                Divider().opacity(0.2)
                            }
                        }
                    }
                }
            }
        }
    }

    private var authorsSection: some View {
        let authors = viewModel.topAuthors(from: filteredLogs, hidden: store.hiddenAuthors)
        return Group {
            if !authors.isEmpty {
                AppSurfaceCard {
                    VStack(alignment: .leading, spacing: 8) {
                        AppSectionHeader(
                            title: "Top authors",
                            subtitle: "Swipe to hide from list",
                            systemImage: "person.2.fill"
                        )
                        ForEach(Array(authors.enumerated()), id: \.element.name) { index, author in
                            AuthorRankCell(name: author.name, count: author.count, rank: index + 1)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        FeedbackEffects.buttonTap()
                                        store.hideAuthor(author.name)
                                    } label: {
                                        Label("Hide author", systemImage: "eye.slash")
                                    }
                                }
                            if index < authors.count - 1 {
                                Divider().opacity(0.2)
                            }
                        }
                    }
                }
            }
        }
    }

    private func pinGenreTapped() {
        guard viewModel.validateGenreField() else { return }
        FeedbackEffects.saveOrComplete()
        store.addFavoriteGenre(viewModel.genreField)
        FeedbackEffects.playSystemSound(1104)
        viewModel.genreField = ""
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
            chartAnimation += 1
        }
    }

    private func addFirstBookTapped() {
        FeedbackEffects.saveOrComplete()
        FeedbackEffects.playSystemSound(1104)
        withAnimation(.easeInOut(duration: 0.3)) {
            tabCoordinator.openBookshelf()
        }
    }
}

private struct GenrePieChart: View {
    let segments: [(genre: String, count: Int)]
    var animated: CGFloat

    var body: some View {
        Canvas { context, size in
            let radius = min(size.width, size.height) / 2.4
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let total = max(1, segments.reduce(0) { $0 + $1.count })
            var start = -Double.pi / 2
            if segments.isEmpty {
                let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
                context.stroke(Path(ellipseIn: rect), with: .color(Color.appTextSecondary.opacity(0.35)), lineWidth: 2)
                return
            }
            for (index, segment) in segments.enumerated() {
                let sweep = Double.pi * 2 * Double(segment.count) / Double(total)
                var path = Path()
                path.move(to: center)
                path.addArc(
                    center: center,
                    radius: radius * (0.85 + 0.02 * sin(Double(index) + Double(animated))),
                    startAngle: .radians(start),
                    endAngle: .radians(start + sweep),
                    clockwise: false
                )
                path.closeSubpath()
                let colors: [Color] = [Color.appPrimary, Color.appAccent, Color.appSurface, Color.appPrimary.opacity(0.6)]
                context.fill(path, with: .color(colors[index % colors.count].opacity(0.85)))
                start += sweep
            }
        }
        .padding(8)
        .appDepthInset(cornerRadius: 16)
    }
}

private struct MonthBarChart: View {
    let months: [MonthData]
    var animated: CGFloat

    var body: some View {
        Canvas { context, size in
            let padding: CGFloat = 18
            let count = max(months.count, 1)
            let slot = (size.width - padding * 2) / CGFloat(count)
            let barWidth = min(26, slot * 0.6)
            let maxCount = CGFloat(max(1, months.map(\.count).max() ?? 1))
            let baseline = size.height - padding
            if months.isEmpty {
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: padding, y: baseline))
                        path.addLine(to: CGPoint(x: size.width - padding, y: baseline))
                    },
                    with: .color(Color.appTextSecondary.opacity(0.35)),
                    lineWidth: 1
                )
                return
            }
            for (index, month) in months.enumerated() {
                let x = padding + CGFloat(index) * slot + (slot - barWidth) / 2
                let animatedBoost = 0.9 + 0.05 * sin(Double(index) + Double(animated))
                let height = (size.height - padding * 2) * CGFloat(month.count) / maxCount * CGFloat(animatedBoost)
                let rect = CGRect(x: x, y: baseline - height, width: barWidth, height: height)
                context.fill(Path(roundedRect: rect, cornerRadius: 6), with: .color(Color.appAccent.opacity(0.9)))
            }
        }
        .padding(8)
        .appDepthInset(cornerRadius: 16)
    }
}
