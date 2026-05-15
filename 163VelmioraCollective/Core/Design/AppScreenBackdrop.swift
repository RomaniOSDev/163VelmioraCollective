import SwiftUI
import UIKit

/// Общий атмосферный фон экрана (градиент + свечение).
struct AppScreenBackdrop: View {
    var body: some View {
        ZStack {
            AppGradients.screenBackground

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.appPrimary.opacity(0.18), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 320)
                .offset(x: -100, y: -200)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.appAccent.opacity(0.14), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 140
                    )
                )
                .frame(width: 280, height: 280)
                .offset(x: 130, y: 340)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

// MARK: - UIKit

enum AppAppearance {
    private static let surfaceUIColor = UIColor(red: 0.11, green: 0.16, blue: 0.24, alpha: 1)

    static func configure() {
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        UIScrollView.appearance().backgroundColor = .clear
        UICollectionView.appearance().backgroundColor = .clear

        let nav = UINavigationBarAppearance()
        nav.configureWithDefaultBackground()
        nav.backgroundColor = surfaceUIColor.withAlphaComponent(0.92)
        nav.titleTextAttributes = [.foregroundColor: UIColor.white]
        nav.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
    }
}

// MARK: - Modifiers

private struct AppScreenBackdropModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            AppScreenBackdrop()
            content
        }
    }
}

extension View {
    /// Градиент под контентом (внутри NavigationStack, не снаружи).
    func appScreenBackdrop() -> some View {
        modifier(AppScreenBackdropModifier())
    }

    func appNavigationRoot() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
    }
}

/// Экран с NavigationStack: фон внутри стека навигации.
struct AppNavigationScreen<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        NavigationStack {
            content()
                .appScreenBackdrop()
        }
        .appNavigationRoot()
    }
}
