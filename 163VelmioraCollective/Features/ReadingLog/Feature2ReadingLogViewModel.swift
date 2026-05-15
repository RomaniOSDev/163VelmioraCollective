import Combine
import SwiftUI

final class Feature2ReadingLogViewModel: ObservableObject {
    @Published var isPresentingForm = false
    @Published var editingEntry: ReadingLogEntry?
    @Published var titleText = ""
    @Published var authorText = ""
    @Published var genreText = ""
    @Published var tagsText = ""
    @Published var seriesNameText = ""
    @Published var seriesVolumeText = ""
    @Published var notesText = ""
    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var rating = 3
    @Published var titleShake: CGFloat = 0
    @Published var authorShake: CGFloat = 0
    @Published var titleError = ""
    @Published var authorError = ""

    @Published var searchText = ""
    @Published var sortMode: LogSortMode = .finishNewest
    @Published var filterGenre = ""
    @Published var filterTag = ""

    func beginAdd() {
        editingEntry = nil
        titleText = ""
        authorText = ""
        genreText = ""
        tagsText = ""
        seriesNameText = ""
        seriesVolumeText = ""
        notesText = ""
        startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        endDate = Date()
        rating = 3
        clearErrors()
        isPresentingForm = true
    }

    func beginEdit(_ entry: ReadingLogEntry) {
        editingEntry = entry
        titleText = entry.title
        authorText = entry.author
        genreText = entry.genre
        tagsText = entry.tags.joined(separator: ", ")
        seriesNameText = entry.seriesName
        seriesVolumeText = entry.seriesVolume
        notesText = entry.notes
        startDate = entry.startDate
        endDate = entry.endDate
        rating = entry.rating
        clearErrors()
        isPresentingForm = true
    }

    func clearErrors() {
        titleError = ""
        authorError = ""
    }

    func validate() -> Bool {
        var ok = true
        if titleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            titleError = "Title is required."
            withAnimation(.default) { titleShake += 1 }
            ok = false
        }
        if authorText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            authorError = "Author is required."
            withAnimation(.default) { authorShake += 1 }
            ok = false
        }
        if endDate < startDate {
            authorError = "Finish date must be after start date."
            withAnimation(.default) { authorShake += 1 }
            ok = false
        }
        if !ok {
            FeedbackEffects.invalidInput()
        }
        return ok
    }
}
