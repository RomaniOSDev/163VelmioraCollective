import SwiftUI

// MARK: - Bookshelf cell

struct ShelfBookCell: View {
    let book: ShelfBook
    var highlighted: Bool = false

    var body: some View {
        AppSurfaceCard(highlighted: highlighted) {
            HStack(alignment: .top, spacing: 14) {
                BookCoverThumbnail(title: book.title, genre: book.genre, showGenreStripe: true)
                    .frame(width: 62, height: 90)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(book.title)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(Color.appTextPrimary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.85)
                            Text(book.author)
                                .font(.subheadline)
                                .foregroundStyle(Color.appTextSecondary)
                                .lineLimit(1)
                        }
                        Spacer(minLength: 8)
                        ReadStatusBadge(isRead: book.isRead)
                    }

                    SeriesSubtitle(seriesName: book.seriesName, seriesVolume: book.seriesVolume)

                    if !book.genre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(GenreStripe.stripeColor(for: book.genre))
                                .frame(width: 6, height: 6)
                            Text(book.genre)
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                                .lineLimit(1)
                        }
                    }

                    TagChipRow(tags: book.tags)

                    if !book.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "note.text")
                                .font(.caption2)
                                .foregroundStyle(Color.appTextSecondary)
                            Text(book.notes)
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                                .lineLimit(2)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Reading log cell

struct ReadingLogCell: View {
    let entry: ReadingLogEntry
    var highlighted: Bool = false

    private var daySpan: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: entry.startDate)
        let end = calendar.startOfDay(for: entry.endDate)
        return max(1, calendar.dateComponents([.day], from: start, to: end).day ?? 1)
    }

    var body: some View {
        AppSurfaceCard(highlighted: highlighted) {
            HStack(alignment: .top, spacing: 14) {
                BookCoverThumbnail(title: entry.title, genre: entry.genre, showGenreStripe: true)
                    .frame(width: 54, height: 80)

                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(2)
                    Text(entry.author)
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(1)

                    SeriesSubtitle(seriesName: entry.seriesName, seriesVolume: entry.seriesVolume)

                    HStack(spacing: 8) {
                        Label {
                            Text(entry.startDate, style: .date)
                        } icon: {
                            Image(systemName: "calendar")
                        }
                        Text("→")
                            .foregroundStyle(Color.appTextSecondary)
                        Text(entry.endDate, style: .date)
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.appTextSecondary)

                    HStack {
                        StarRatingRow(rating: entry.rating)
                        Spacer()
                        Text("\(daySpan)d")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.appPrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.appPrimary.opacity(0.15)))
                    }

                    TagChipRow(tags: entry.tags)

                    if !entry.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(entry.notes)
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                            .lineLimit(2)
                            .padding(.top, 2)
                    }
                }
            }
        }
    }
}

// MARK: - Reminder cell

struct ReminderCell: View {
    let reminder: InAppReminder
    var isOverdue: Bool = false
    var onEdit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        AppSurfaceCard(accentBorder: isOverdue) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isOverdue ? Color.appAccent.opacity(0.2) : Color.appPrimary.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: isOverdue ? "bell.badge.fill" : "bell")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(isOverdue ? Color.appAccent : Color.appPrimary)
                }

                Button(action: onEdit) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(reminder.title)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color.appTextPrimary)
                            .multilineTextAlignment(.leading)
                        Text(reminder.dueDate, style: .date)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(isOverdue ? Color.appAccent : Color.appTextSecondary)
                        if !reminder.detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text(reminder.detail)
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                                .lineLimit(2)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .font(.title3)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color.appTextSecondary)
                }
                .accessibilityLabel("Delete reminder")
            }
        }
    }
}

// MARK: - Achievement cell

struct AchievementBadgeCell: View {
    let achievement: AchievementId
    let unlocked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    Circle()
                        .fill(unlocked ? Color.appPrimary.opacity(0.2) : Color.appSurface.opacity(0.5))
                        .frame(width: 40, height: 40)
                    Image(systemName: unlocked ? "seal.fill" : "lock.fill")
                        .font(.body.weight(.bold))
                        .foregroundStyle(unlocked ? Color.appPrimary : Color.appTextSecondary)
                }
                Spacer()
                if unlocked {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(Color.appAccent)
                }
            }
            Text(achievement.title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Text(achievement.detail)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
        .appDepthCard(
            highlighted: unlocked,
            accentBorder: unlocked,
            shadow: unlocked ? .card : .soft
        )
        .opacity(unlocked ? 1 : 0.88)
    }
}

// MARK: - Insights cells

struct ReadingGoalCard: View {
    @Binding var goalYear: Int
    @Binding var goalTarget: Int
    let finished: Int

    private var progress: Double {
        guard goalTarget > 0 else { return 0 }
        return min(1, Double(finished) / Double(goalTarget))
    }

    var body: some View {
        AppSurfaceCard(accentBorder: goalTarget > 0 && finished >= goalTarget) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    AppSectionHeader(title: "Reading goal", subtitle: "Yearly target", systemImage: "target")
                    Spacer()
                    if goalTarget > 0 {
                        Text("\(Int(progress * 100))%")
                            .font(.title2.weight(.black))
                            .foregroundStyle(Color.appAccent)
                    }
                }

                HStack(spacing: 10) {
                    AppStatPill(title: "Finished", value: "\(finished)", tint: .appAccent)
                    AppStatPill(title: "Target", value: goalTarget > 0 ? "\(goalTarget)" : "—", tint: .appPrimary)
                }

                Stepper(value: $goalYear, in: yearRange, step: 1) {
                    Text("Year \(goalYear)")
                        .foregroundStyle(Color.appTextPrimary)
                }
                .tint(Color.appPrimary)

                Stepper(value: $goalTarget, in: 0...500, step: 1) {
                    Text("Books to read: \(goalTarget)")
                        .foregroundStyle(Color.appTextPrimary)
                }
                .tint(Color.appPrimary)

                if goalTarget > 0 {
                    ProgressView(value: progress)
                        .tint(Color.appAccent)
                        .scaleEffect(x: 1, y: 1.4, anchor: .center)
                    Text(finished >= goalTarget ? "Goal reached — great work!" : "\(goalTarget - finished) books left this year")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                } else {
                    Text("Set a target to track progress through the year.")
                        .font(.footnote)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
    }

    private var yearRange: ClosedRange<Int> {
        let current = Calendar.current.component(.year, from: Date())
        return (current - 5)...(current + 2)
    }
}

struct AuthorRankCell: View {
    let name: String
    let count: Int
    let rank: Int

    var body: some View {
        HStack(spacing: 14) {
            Text("\(rank)")
                .font(.caption.weight(.black))
                .foregroundStyle(rank <= 3 ? Color.appOnPrimary : Color.appTextSecondary)
                .frame(width: 28, height: 28)
                .background(
                    Circle().fill(
                        rank <= 3
                            ? AnyShapeStyle(AppGradients.primaryButton)
                            : AnyShapeStyle(Color.appSurface)
                    )
                )
            Text(name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
            Spacer()
            Text("\(count)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.appAccent)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.appAccent.opacity(0.15)))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}

struct GenrePinCell: View {
    let genre: String

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(GenreStripe.stripeColor(for: genre))
                .frame(width: 10, height: 10)
            Text(genre)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
            Spacer()
            Image(systemName: "pin.fill")
                .font(.caption)
                .foregroundStyle(Color.appPrimary)
        }
        .padding(.vertical, 10)
    }
}

struct InsightsSummaryCard: View {
    let booksFinished: Int
    let topGenre: String
    let topAuthor: String
    let averageDays: Double

    var body: some View {
        AppSurfaceCard {
            VStack(alignment: .leading, spacing: 12) {
                AppSectionHeader(title: "Summary", systemImage: "chart.bar.doc.horizontal")
                AppMetricRow(label: "Books finished", value: "\(booksFinished)", icon: "book.fill")
                Divider().opacity(0.25)
                AppMetricRow(label: "Leading genre", value: topGenre, icon: "paintpalette.fill")
                AppMetricRow(label: "Leading author", value: topAuthor, icon: "person.fill")
                AppMetricRow(label: "Avg. reading span", value: String(format: "%.1f days", averageDays), icon: "clock.fill")
            }
        }
    }
}
