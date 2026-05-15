import SwiftUI

struct Feature2ReadingLogView: View {
    @EnvironmentObject private var store: LibraryAppStorage
    @StateObject private var viewModel = Feature2ReadingLogViewModel()
    @State private var showSuccessCheck = false

    private var displayedEntries: [ReadingLogEntry] {
        var list = store.readingLog
        let q = viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !q.isEmpty {
            list = list.filter { entry in
                entry.title.localizedCaseInsensitiveContains(q)
                    || entry.author.localizedCaseInsensitiveContains(q)
                    || entry.genre.localizedCaseInsensitiveContains(q)
                    || entry.seriesName.localizedCaseInsensitiveContains(q)
                    || entry.notes.localizedCaseInsensitiveContains(q)
                    || entry.tags.joined(separator: ",").localizedCaseInsensitiveContains(q)
            }
        }
        if !viewModel.filterGenre.isEmpty {
            let g = viewModel.filterGenre
            list = list.filter { $0.genre.localizedCaseInsensitiveContains(g) }
        }
        if !viewModel.filterTag.isEmpty {
            let t = viewModel.filterTag
            list = list.filter { entry in
                entry.tags.contains { $0.caseInsensitiveCompare(t) == .orderedSame }
            }
        }
        switch viewModel.sortMode {
        case .finishNewest:
            list.sort { $0.endDate > $1.endDate }
        case .finishOldest:
            list.sort { $0.endDate < $1.endDate }
        case .titleAZ:
            list.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .authorAZ:
            list.sort { $0.author.localizedCaseInsensitiveCompare($1.author) == .orderedAscending }
        case .ratingHigh:
            list.sort { $0.rating > $1.rating }
        }
        return list
    }

    private var logGenres: [String] {
        let set = Set(store.readingLog.map { $0.genre.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty })
        return set.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    private var logTags: [String] {
        var set = Set<String>()
        for entry in store.readingLog {
            for tag in entry.tags {
                let t = tag.trimmingCharacters(in: .whitespacesAndNewlines)
                if !t.isEmpty { set.insert(t) }
            }
        }
        return set.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    private var activeFilterChips: [FilterChip] {
        var chips: [FilterChip] = []
        if !viewModel.filterGenre.isEmpty {
            chips.append(FilterChip(id: "genre", label: viewModel.filterGenre) {
                viewModel.filterGenre = ""
            })
        }
        if !viewModel.filterTag.isEmpty {
            chips.append(FilterChip(id: "tag", label: "#\(viewModel.filterTag)") {
                viewModel.filterTag = ""
            })
        }
        return chips
    }

    private var averageRating: String {
        guard !store.readingLog.isEmpty else { return "—" }
        let sum = store.readingLog.reduce(0) { $0 + $1.rating }
        return String(format: "%.1f", Double(sum) / Double(store.readingLog.count))
    }

    var body: some View {
        AppNavigationScreen {
            Group {
                if store.readingLog.isEmpty {
                    emptyState
                } else {
                    logList
                }
            }
            .navigationTitle("Reading Log")
            .navigationBarTitleDisplayMode(.inline)
            .appToolbarChrome()
            .searchable(text: $viewModel.searchText, prompt: "Search log…")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !store.readingLog.isEmpty { filterMenu }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        FeedbackEffects.buttonTap()
                        viewModel.beginAdd()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.appPrimary)
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .accessibilityLabel("Add log entry")
                }
            }
            .sheet(isPresented: $viewModel.isPresentingForm) { logFormSheet }
            .successCheckmark(trigger: $showSuccessCheck)
        }
    }

    private var filterMenu: some View {
        Menu {
            Section("Sort") {
                ForEach(LogSortMode.allCases) { mode in
                    Button {
                        FeedbackEffects.buttonTap()
                        viewModel.sortMode = mode
                    } label: {
                        Label(mode.title, systemImage: viewModel.sortMode == mode ? "checkmark" : "arrow.up.arrow.down")
                    }
                }
            }
            Section("Genre") {
                Button("All genres") { viewModel.filterGenre = "" }
                ForEach(logGenres, id: \.self) { g in
                    Button(g) { viewModel.filterGenre = g }
                }
            }
            Section("Tag") {
                Button("All tags") { viewModel.filterTag = "" }
                ForEach(logTags, id: \.self) { t in
                    Button(t) { viewModel.filterTag = t }
                }
            }
        } label: {
            Image(systemName: activeFilterChips.isEmpty ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                .foregroundStyle(Color.appPrimary)
                .frame(minWidth: 44, minHeight: 44)
        }
    }

    private var emptyState: some View {
        ScrollView {
            AppEmptyState(
                systemImage: "book.pages.fill",
                title: "No books logged yet",
                message: "Capture dates, ratings, and notes for every book you finish.",
                actionTitle: "Log your first read",
                action: {
                    FeedbackEffects.buttonTap()
                    viewModel.beginAdd()
                }
            )
        }
    }

    private var logList: some View {
        List {
            Section {
                HStack(spacing: 10) {
                    AppStatPill(title: "Entries", value: "\(store.readingLog.count)")
                    AppStatPill(title: "Avg rating", value: averageRating, tint: .appAccent)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            if !activeFilterChips.isEmpty {
                Section {
                    FilterChipBar(chips: activeFilterChips) {
                        viewModel.filterGenre = ""
                        viewModel.filterTag = ""
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }

            if displayedEntries.isEmpty {
                Section {
                    Text("No matches for current filters.")
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .listRowBackground(Color.clear)
                }
            } else {
                Section {
                    ForEach(displayedEntries) { entry in
                        ReadingLogCell(
                            entry: entry,
                            highlighted: store.lastPulsingLogEntryId == entry.id
                        )
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .animation(.easeInOut(duration: 0.35), value: store.lastPulsingLogEntryId)
                        .onTapGesture {
                            FeedbackEffects.buttonTap()
                            viewModel.beginEdit(entry)
                        }
                        .contextMenu {
                            Button("Edit") { viewModel.beginEdit(entry) }
                            Button(role: .destructive) {
                                store.deleteReadingLogEntry(id: entry.id)
                            } label: {
                                Text("Delete")
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                store.deleteReadingLogEntry(id: entry.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    AppSectionHeader(
                        title: "Finished reads",
                        subtitle: "\(displayedEntries.count) entries · \(viewModel.sortMode.title)"
                    )
                    .textCase(nil)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 0, trailing: 16))
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private var logFormSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    AppFormSection(title: "Book") {
                        AppFormTextField(placeholder: "Title", text: $viewModel.titleText)
                            .shake(trigger: viewModel.titleShake)
                        if !viewModel.titleError.isEmpty {
                            AppFormErrorText(message: viewModel.titleError)
                        }
                        AppFormTextField(placeholder: "Author", text: $viewModel.authorText)
                            .shake(trigger: viewModel.authorShake)
                        if !viewModel.authorError.isEmpty {
                            AppFormErrorText(message: viewModel.authorError)
                        }
                        AppFormTextField(placeholder: "Genre", text: $viewModel.genreText)
                    }

                    AppFormSection(title: "Series") {
                        AppFormTextField(placeholder: "Series name", text: $viewModel.seriesNameText)
                        AppFormTextField(placeholder: "Volume or #", text: $viewModel.seriesVolumeText)
                    }

                    AppFormSection(title: "Tags") {
                        AppFormTextField(placeholder: "Comma-separated tags", text: $viewModel.tagsText)
                    }

                    AppFormSection(title: "Notes") {
                        AppFormNotesEditor(text: $viewModel.notesText, minHeight: 100)
                    }

                    AppFormSection(title: "Dates") {
                        AppFormDatePicker(title: "Start", date: $viewModel.startDate)
                        AppFormDatePicker(title: "Finish", date: $viewModel.endDate)
                    }

                    AppFormSection(title: "Rating") {
                        StarRatingRow(rating: viewModel.rating)
                        Slider(value: Binding(
                            get: { Double(viewModel.rating) },
                            set: { viewModel.rating = Int($0.rounded()) }
                        ), in: 1...5, step: 1)
                        .tint(Color.appAccent)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 4)
                    }
                }
                .padding(16)
            }
            .appFormScreenBackground()
            .navigationTitle(viewModel.editingEntry == nil ? "New Entry" : "Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        FeedbackEffects.buttonTap()
                        viewModel.isPresentingForm = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveLog() }
                        .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func saveLog() {
        guard viewModel.validate() else { return }
        FeedbackEffects.saveOrComplete()
        let tags = TagParsing.tags(fromCommaSeparated: viewModel.tagsText)
        let genreTrimmed = viewModel.genreText.trimmingCharacters(in: .whitespacesAndNewlines)
        let safeGenre = genreTrimmed.isEmpty ? "General" : genreTrimmed
        if let existing = viewModel.editingEntry {
            let updated = ReadingLogEntry(
                id: existing.id,
                title: viewModel.titleText.trimmingCharacters(in: .whitespacesAndNewlines),
                author: viewModel.authorText.trimmingCharacters(in: .whitespacesAndNewlines),
                genre: safeGenre,
                startDate: viewModel.startDate,
                endDate: viewModel.endDate,
                rating: viewModel.rating,
                notes: viewModel.notesText,
                tags: tags,
                seriesName: viewModel.seriesNameText.trimmingCharacters(in: .whitespacesAndNewlines),
                seriesVolume: viewModel.seriesVolumeText.trimmingCharacters(in: .whitespacesAndNewlines),
                loggedAt: existing.loggedAt
            )
            store.updateReadingLogEntry(updated)
            FeedbackEffects.successPing()
            showSuccessCheck = true
        } else {
            let entry = ReadingLogEntry(
                id: UUID(),
                title: viewModel.titleText.trimmingCharacters(in: .whitespacesAndNewlines),
                author: viewModel.authorText.trimmingCharacters(in: .whitespacesAndNewlines),
                genre: safeGenre,
                startDate: viewModel.startDate,
                endDate: viewModel.endDate,
                rating: viewModel.rating,
                notes: viewModel.notesText,
                tags: tags,
                seriesName: viewModel.seriesNameText.trimmingCharacters(in: .whitespacesAndNewlines),
                seriesVolume: viewModel.seriesVolumeText.trimmingCharacters(in: .whitespacesAndNewlines),
                loggedAt: Date()
            )
            guard store.addReadingLogEntry(entry) else { return }
            FeedbackEffects.playSystemSound(1104)
            showSuccessCheck = true
        }
        viewModel.isPresentingForm = false
    }
}
