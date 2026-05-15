import SwiftUI

// MARK: - Hero

struct HomeHeroBanner: View {
    let greeting: String
    let streakDays: Int
    let subtitle: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HomeHero")
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()

            AppGradients.heroScrim

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(greeting)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(2)
                }
                Spacer()
                if streakDays > 0 {
                    VStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .font(.title3)
                            .foregroundStyle(Color.appAccent)
                        Text("\(streakDays)")
                            .font(.title3.weight(.black))
                            .foregroundStyle(Color.appTextPrimary)
                        Text("day streak")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .padding(12)
                    .appDepthCard(cornerRadius: 14, shadow: .soft)
                }
            }
            .padding(16)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppGradients.borderAccent, lineWidth: 1)
        )
        .compositingGroup()
        .appDepthShadow(.elevated)
    }
}

// MARK: - Stat widget

struct HomeStatWidget: View {
    let title: String
    let value: String
    let imageName: String
    var tint: Color = .appPrimary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(tint.opacity(0.4), lineWidth: 1)
                    )

                Text(value)
                    .font(.title2.weight(.black))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .appDepthCard(cornerRadius: 16, shadow: .soft)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(tint.opacity(0.18), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Goal widget

struct HomeGoalWidget: View {
    let year: Int
    let finished: Int
    let target: Int
    let progress: Double
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(Color.appSurface, lineWidth: 8)
                        .frame(width: 72, height: 72)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [Color.appPrimary, Color.appAccent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 72, height: 72)
                        .rotationEffect(.degrees(-90))
                    Image("WidgetGoal")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Reading goal \(year)")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                    if target > 0 {
                        Text("\(finished) of \(target) books")
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                        ProgressView(value: progress)
                            .tint(Color.appAccent)
                    } else {
                        Text("Set a yearly target in Insights")
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appTextSecondary)
            }
            .padding(14)
            .appDepthCard(cornerRadius: 18, accentBorder: target > 0, shadow: .card)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Quick actions

struct HomeQuickAction: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
    let systemImage: String
    let action: () -> Void
}

struct HomeQuickActionsGrid: View {
    let actions: [HomeQuickAction]

    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(actions) { item in
                Button(action: item.action) {
                    HStack(spacing: 10) {
                        Image(item.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(Color.appTextPrimary)
                                .lineLimit(1)
                            Text(item.subtitle)
                                .font(.caption2)
                                .foregroundStyle(Color.appTextSecondary)
                                .lineLimit(1)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
                    .appDepthCard(cornerRadius: 16, shadow: .soft)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// MARK: - Book mini card

struct HomeBookMiniCard: View {
    let book: ShelfBook
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                BookCoverThumbnail(title: book.title, genre: book.genre, showGenreStripe: true)
                    .frame(width: 48, height: 68)
                VStack(alignment: .leading, spacing: 4) {
                    Text(book.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(2)
                    Text(book.author)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(1)
                    ReadStatusBadge(isRead: book.isRead)
                }
                Spacer()
            }
            .padding(10)
            .appDepthInset(cornerRadius: 14)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Log mini card

struct HomeLogMiniCard: View {
    let entry: ReadingLogEntry
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image("WidgetJournal")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(1)
                    StarRatingRow(rating: entry.rating, compact: true)
                    Text(entry.endDate, style: .date)
                        .font(.caption2)
                        .foregroundStyle(Color.appTextSecondary)
                }
                Spacer()
            }
            .padding(10)
            .appDepthInset(cornerRadius: 14)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Reminder widget

struct HomeRemindersWidget: View {
    let reminders: [InAppReminder]
    let onOpenSettings: () -> Void

    var body: some View {
        AppSurfaceCard(accentBorder: !reminders.isEmpty) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    AppSectionHeader(title: "Reminders", subtitle: "In-app only", systemImage: "bell.badge")
                    Spacer()
                    Button("Manage", action: onOpenSettings)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appPrimary)
                }
                if reminders.isEmpty {
                    Text("No due reminders — add one in Settings.")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                } else {
                    ForEach(reminders.prefix(3)) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appTextPrimary)
                                Text(item.dueDate, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(Color.appAccent)
                            }
                            Spacer()
                        }
                        if item.id != reminders.prefix(3).last?.id {
                            Divider().opacity(0.2)
                        }
                    }
                }
            }
        }
    }
}
