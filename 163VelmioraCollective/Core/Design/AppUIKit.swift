import SwiftUI

// MARK: - Surface card

struct AppSurfaceCard<Content: View>: View {
    var highlighted: Bool = false
    var accentBorder: Bool = false
    var elevated: Bool = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appDepthCard(
                highlighted: highlighted,
                accentBorder: accentBorder,
                shadow: elevated ? .elevated : (highlighted ? .card : .card)
            )
    }
}

// MARK: - Section header

struct AppSectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var systemImage: String? = nil
    var trailing: String? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appPrimary)
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.appPrimary.opacity(0.28), Color.appPrimary.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            Spacer(minLength: 0)
            if let trailing {
                Text(trailing)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color.appSurface.opacity(0.9)))
            }
        }
    }
}

// MARK: - Metric row

struct AppMetricRow: View {
    let label: String
    let value: String
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 12) {
            if let icon {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appPrimary)
                    .frame(width: 26)
            }
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
            Spacer(minLength: 8)
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(.vertical, 3)
    }
}

// MARK: - Stat pill

struct AppStatPill: View {
    let title: String
    let value: String
    var tint: Color = .appPrimary

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color.appTextSecondary)
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .appDepthCard(cornerRadius: 14, shadow: .soft)
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(tint.opacity(0.22), lineWidth: 1)
        )
    }
}

// MARK: - Empty state

struct AppEmptyState: View {
    let systemImage: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.appPrimary.opacity(0.22), Color.appAccent.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                Image(systemName: systemImage)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(Color.appPrimary)
            }
            VStack(spacing: 8) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)
                Text(message)
                    .font(.body)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
            }
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .buttonStyle(PrimaryProminentButtonStyle())
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .padding(.horizontal, 20)
    }
}

// MARK: - Filter chips

struct FilterChip: Identifiable {
    let id: String
    let label: String
    let onRemove: () -> Void
}

struct FilterChipBar: View {
    let chips: [FilterChip]
    var onClearAll: (() -> Void)? = nil

    var body: some View {
        if !chips.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(chips) { chip in
                        HStack(spacing: 6) {
                            Text(chip.label)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.appTextPrimary)
                            Button {
                                FeedbackEffects.buttonTap()
                                chip.onRemove()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(AppGradients.surfaceCard))
                        .overlay(Capsule().stroke(Color.appPrimary.opacity(0.3), lineWidth: 1))
                    }
                    if let onClearAll {
                        Button("Clear all") {
                            FeedbackEffects.buttonTap()
                            onClearAll()
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appAccent)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
            }
        }
    }
}

// MARK: - Tags & badges

struct TagChipRow: View {
    let tags: [String]
    var maxVisible: Int = 6

    var body: some View {
        if !tags.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(Array(tags.prefix(maxVisible).enumerated()), id: \.offset) { _, tag in
                        Text(tag)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color.appTextPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(Color.appSurface.opacity(0.45))
                                    .overlay(Capsule().stroke(Color.appPrimary.opacity(0.2), lineWidth: 1))
                            )
                    }
                    if tags.count > maxVisible {
                        Text("+\(tags.count - maxVisible)")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
        }
    }
}

struct ReadStatusBadge: View {
    let isRead: Bool

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isRead ? "checkmark.circle.fill" : "book.closed")
                .font(.caption2.weight(.bold))
            Text(isRead ? "Read" : "Unread")
                .font(.caption.weight(.bold))
        }
        .foregroundStyle(isRead ? Color.appOnPrimary : Color.appTextPrimary)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule().fill(
                isRead
                    ? AnyShapeStyle(AppGradients.primaryButton)
                    : AnyShapeStyle(Color.appSurface.opacity(0.45))
            )
        )
    }
}

struct StarRatingRow: View {
    let rating: Int
    var maxStars: Int = 5
    var compact: Bool = false

    var body: some View {
        HStack(spacing: compact ? 2 : 4) {
            ForEach(1...maxStars, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(compact ? .caption2 : .caption)
                    .foregroundStyle(star <= rating ? Color.appAccent : Color.appTextSecondary.opacity(0.35))
            }
        }
        .accessibilityLabel("Rating \(rating) out of \(maxStars)")
    }
}

struct SeriesSubtitle: View {
    let seriesName: String
    let seriesVolume: String

    var body: some View {
        let name = seriesName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !name.isEmpty {
            let vol = seriesVolume.trimmingCharacters(in: .whitespacesAndNewlines)
            HStack(spacing: 4) {
                Image(systemName: "books.vertical")
                    .font(.caption2)
                Text(vol.isEmpty ? name : "\(name) · #\(vol)")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(Color.appAccent)
            .lineLimit(1)
        }
    }
}

// MARK: - Form styling

struct AppFormSection<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.appTextSecondary)
                .padding(.leading, 4)
            VStack(alignment: .leading, spacing: 12) {
                content()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appDepthCard(cornerRadius: 16, shadow: .soft)
        }
    }
}

struct AppFormTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .foregroundStyle(Color.appTextPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appDepthInset(cornerRadius: 12)
    }
}

struct AppFormNotesEditor: View {
    @Binding var text: String
    var minHeight: CGFloat = 110

    var body: some View {
        TextEditor(text: $text)
            .frame(minHeight: minHeight)
            .foregroundStyle(Color.appTextPrimary)
            .scrollContentBackground(.hidden)
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .appDepthInset(cornerRadius: 12)
    }
}

struct AppFormDivider: View {
    var body: some View {
        Divider()
            .opacity(0.2)
            .padding(.vertical, 2)
    }
}

struct AppFormErrorText: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.footnote)
            .foregroundStyle(Color.red.opacity(0.9))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
    }
}

struct AppFormToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(title, isOn: $isOn)
            .tint(Color.appPrimary)
            .foregroundStyle(Color.appTextPrimary)
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
    }
}

struct AppFormDatePicker: View {
    let title: String
    @Binding var date: Date
    var components: DatePickerComponents = .date

    var body: some View {
        DatePicker(title, selection: $date, displayedComponents: components)
            .tint(Color.appPrimary)
            .foregroundStyle(Color.appTextPrimary)
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
    }
}

// MARK: - Settings row

struct SettingsNavRow: View {
    let title: String
    let systemImage: String
    var tint: Color = .appPrimary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [tint.opacity(0.28), tint.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    Image(systemName: systemImage)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(tint)
                }
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appTextSecondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Journal segment bar

struct JournalSegmentBar: View {
    @Binding var selection: Int
    let titles: [String]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(titles.indices, id: \.self) { index in
                let selected = selection == index
                Button {
                    FeedbackEffects.buttonTap()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                        selection = index
                    }
                } label: {
                    Text(titles[index])
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(selected ? Color.appOnPrimary : Color.appTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(
                            Group {
                                if selected {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(AppGradients.tabSelected)
                                }
                            }
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .appDepthCard(cornerRadius: 16, shadow: .soft)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
