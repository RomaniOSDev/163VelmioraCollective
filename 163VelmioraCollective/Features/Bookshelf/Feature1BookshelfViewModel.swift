import Combine
import SwiftUI

final class Feature1BookshelfViewModel: ObservableObject {
    @Published var isPresentingEditor = false
    @Published var editingBook: ShelfBook?
    @Published var titleText = ""
    @Published var authorText = ""
    @Published var genreText = ""
    @Published var tagsText = ""
    @Published var seriesNameText = ""
    @Published var seriesVolumeText = ""
    @Published var notesText = ""
    @Published var markRead = false
    @Published var titleShake: CGFloat = 0
    @Published var authorShake: CGFloat = 0
    @Published var titleError = ""
    @Published var authorError = ""
    @Published var successPulse = false

    @Published var searchText = ""
    @Published var sortMode: ShelfSortMode = .dateAddedNewest
    @Published var readFilter: ReadStatusFilter = .all
    @Published var filterGenre: String = ""
    @Published var filterTag: String = ""

    func beginAdd() {
        editingBook = nil
        titleText = ""
        authorText = ""
        genreText = ""
        tagsText = ""
        seriesNameText = ""
        seriesVolumeText = ""
        notesText = ""
        markRead = false
        titleError = ""
        authorError = ""
        isPresentingEditor = true
    }

    func beginEdit(_ book: ShelfBook) {
        editingBook = book
        titleText = book.title
        authorText = book.author
        genreText = book.genre
        tagsText = book.tags.joined(separator: ", ")
        seriesNameText = book.seriesName
        seriesVolumeText = book.seriesVolume
        notesText = book.notes
        markRead = book.isRead
        titleError = ""
        authorError = ""
        isPresentingEditor = true
    }

    func validate() -> Bool {
        var ok = true
        if titleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            titleError = "Title is required."
            withAnimation(.default) {
                titleShake += 1
            }
            ok = false
        } else {
            titleError = ""
        }
        if authorText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            authorError = "Author is required."
            withAnimation(.default) {
                authorShake += 1
            }
            ok = false
        } else {
            authorError = ""
        }
        if !ok {
            FeedbackEffects.invalidInput()
        }
        return ok
    }
}
