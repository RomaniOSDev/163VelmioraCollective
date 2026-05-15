import Combine
import SwiftUI

final class MainTabCoordinator: ObservableObject {
    @Published var selectedTab: AppRootTab = .home
    @Published var journalSegment: Int = 0

    func openHome() {
        selectedTab = .home
    }

    func openBookshelf() {
        selectedTab = .bookshelf
    }

    func openJournal() {
        journalSegment = 0
        selectedTab = .reading
    }

    func openInsights() {
        journalSegment = 1
        selectedTab = .reading
    }

    func openAchievements() {
        selectedTab = .achievements
    }

    func openSettings() {
        selectedTab = .settings
    }
}

enum AppRootTab: Int, CaseIterable, Identifiable, Hashable {
    case home
    case bookshelf
    case reading
    case achievements
    case settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .bookshelf: return "Shelf"
        case .reading: return "Journal"
        case .achievements: return "Badges"
        case .settings: return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .bookshelf: return "books.vertical"
        case .reading: return "book.pages"
        case .achievements: return "medal"
        case .settings: return "gearshape"
        }
    }
}
