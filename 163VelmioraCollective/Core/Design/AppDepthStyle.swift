import SwiftUI

// MARK: - Shared gradients (static, cheap to render)

enum AppGradients {
    /// Основной фон экранов — тёплый сине-сланцевый, не чёрный.
    static let screenBackground = LinearGradient(
        colors: [
            Color(red: 0.14, green: 0.20, blue: 0.30),
            Color.appBackground,
            Color(red: 0.10, green: 0.16, blue: 0.26)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let screenBackgroundSoft = LinearGradient(
        colors: [
            Color.appSurface.opacity(0.35),
            Color.appBackground.opacity(0.15)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let surfaceCard = LinearGradient(
        colors: [
            Color.appSurface.opacity(0.95),
            Color(red: 0.18, green: 0.24, blue: 0.32).opacity(0.92)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let surfaceHighlight = LinearGradient(
        colors: [
            Color.appAccent.opacity(0.20),
            Color.appSurface.opacity(0.90)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let surfaceInset = LinearGradient(
        colors: [
            Color.appSurface.opacity(0.40),
            Color.appSurface.opacity(0.18)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let heroScrim = LinearGradient(
        colors: [
            Color.clear,
            Color.appBackground.opacity(0.55),
            Color.appBackground.opacity(0.88)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let primaryButton = LinearGradient(
        colors: [Color.appPrimary, Color.appPrimary.opacity(0.82)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let primaryButtonPressed = LinearGradient(
        colors: [Color.appPrimary.opacity(0.9), Color.appAccent.opacity(0.75)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let tabSelected = LinearGradient(
        colors: [Color.appPrimary, Color.appAccent.opacity(0.88)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let rimHighlight = LinearGradient(
        colors: [Color.white.opacity(0.16), Color.white.opacity(0.04), Color.clear],
        startPoint: .top,
        endPoint: .bottom
    )

    static let borderAccent = LinearGradient(
        colors: [Color.appPrimary.opacity(0.55), Color.appAccent.opacity(0.35)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let toolbarBackground = LinearGradient(
        colors: [
            Color.appSurface.opacity(0.92),
            Color.appBackground.opacity(0.85)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Shadow presets (single shadow per view — tinted, not pure black)

enum AppShadow {
    case none
    case soft
    case card
    case elevated
    case floating

    private var tint: Color {
        Color(red: 0.04, green: 0.07, blue: 0.14)
    }

    var color: Color {
        switch self {
        case .none: return .clear
        case .soft: return tint.opacity(0.12)
        case .card: return tint.opacity(0.20)
        case .elevated: return tint.opacity(0.26)
        case .floating: return tint.opacity(0.30)
        }
    }

    var radius: CGFloat {
        switch self {
        case .none: return 0
        case .soft: return 4
        case .card: return 8
        case .elevated: return 10
        case .floating: return 12
        }
    }

    var y: CGFloat {
        switch self {
        case .none: return 0
        case .soft: return 2
        case .card: return 4
        case .elevated: return 5
        case .floating: return 6
        }
    }
}

// MARK: - Modifiers

struct AppDepthCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 18
    var highlighted: Bool = false
    var accentBorder: Bool = false
    var shadow: AppShadow = .card

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .background(
                shape.fill(highlighted ? AppGradients.surfaceHighlight : AppGradients.surfaceCard)
            )
            .overlay(shape.stroke(AppGradients.rimHighlight, lineWidth: 1))
            .overlay(
                shape.stroke(
                    accentBorder
                        ? AnyShapeStyle(AppGradients.borderAccent)
                        : AnyShapeStyle(Color.appPrimary.opacity(highlighted ? 0.28 : 0.12)),
                    lineWidth: accentBorder ? 1.5 : 1
                )
            )
            .compositingGroup()
            .shadow(color: shadow.color, radius: shadow.radius, x: 0, y: shadow.y)
    }
}

struct AppDepthInsetModifier: ViewModifier {
    var cornerRadius: CGFloat = 12

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .background(shape.fill(AppGradients.surfaceInset))
            .overlay(shape.stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}

struct AppDepthShadowModifier: ViewModifier {
    var level: AppShadow

    func body(content: Content) -> some View {
        content.shadow(color: level.color, radius: level.radius, x: 0, y: level.y)
    }
}

extension View {
    func appDepthCard(
        cornerRadius: CGFloat = 18,
        highlighted: Bool = false,
        accentBorder: Bool = false,
        shadow: AppShadow = .card
    ) -> some View {
        modifier(AppDepthCardModifier(
            cornerRadius: cornerRadius,
            highlighted: highlighted,
            accentBorder: accentBorder,
            shadow: shadow
        ))
    }

    func appDepthInset(cornerRadius: CGFloat = 12) -> some View {
        modifier(AppDepthInsetModifier(cornerRadius: cornerRadius))
    }

    func appDepthShadow(_ level: AppShadow) -> some View {
        modifier(AppDepthShadowModifier(level: level))
    }

    /// Прозрачный контейнер — виден `AppChromeBackground` из корня.
    func appClearScreenBackground() -> some View {
        background(Color.clear)
    }

    /// Градиентный фон для форм и sheet (не плоский чёрный).
    func appFormScreenBackground() -> some View {
        background(AppGradients.screenBackground.ignoresSafeArea())
    }

    func appToolbarChrome() -> some View {
        toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(AppGradients.toolbarBackground, for: .navigationBar)
    }
}
