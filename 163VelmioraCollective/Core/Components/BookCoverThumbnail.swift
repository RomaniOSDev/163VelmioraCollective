import SwiftUI

struct BookCoverThumbnail: View {
    let title: String
    var genre: String = ""
    var showGenreStripe: Bool = true

    private var initialLetter: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first else { return "?" }
        return String(first).uppercased()
    }

    private var trimmedGenre: String {
        genre.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        HStack(spacing: 0) {
            if showGenreStripe, !trimmedGenre.isEmpty {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(GenreStripe.stripeColor(for: trimmedGenre))
                    .frame(width: 5)
                    .padding(.vertical, 6)
                    .padding(.leading, 4)
            }
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(gradientFill)
                Text(initialLetter)
                    .font(Font.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(SwiftUI.Color.appTextPrimary)
                    .shadow(color: Color.black.opacity(0.25), radius: 1, y: 1)
            }
            .padding(.trailing, 4)
            .padding(.vertical, 4)
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppGradients.surfaceCard)
        )
        .overlay(borderShape)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppGradients.rimHighlight, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var gradientFill: LinearGradient {
        let top: SwiftUI.Color = .appSurface
        let bottom: SwiftUI.Color = .appAccent
        return LinearGradient(
            colors: [top, bottom],
            startPoint: UnitPoint.topLeading,
            endPoint: UnitPoint.bottomTrailing
        )
    }

    private var borderShape: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .stroke(SwiftUI.Color.appAccent, lineWidth: 1)
    }
}
