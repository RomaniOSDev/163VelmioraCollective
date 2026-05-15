import SwiftUI

struct Feature1BookshelfView: View {
    @EnvironmentObject private var store: LibraryAppStorage
    @StateObject private var viewModel = Feature1BookshelfViewModel()
    @State private var showSuccessCheck = false
    @State private var fabPulse: CGFloat = 1

    private var displayedBooks: [ShelfBook] {
        var list = store.shelfBooks
        let q = viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !q.isEmpty {
            list = list.filter { book in
                book.title.localizedCaseInsensitiveContains(q)
                    || book.author.localizedCaseInsensitiveContains(q)
                    || book.genre.localizedCaseInsensitiveContains(q)
                    || book.seriesName.localizedCaseInsensitiveContains(q)
                    || book.notes.localizedCaseInsensitiveContains(q)
                    || book.tags.joined(separator: ",").localizedCaseInsensitiveContains(q)
            }
        }
        switch viewModel.readFilter {
        case .readOnly:
            list = list.filter(\.isRead)
        case .unreadOnly:
            list = list.filter { !$0.isRead }
        case .all:
            break
        }
        if !viewModel.filterGenre.isEmpty {
            let g = viewModel.filterGenre
            list = list.filter { $0.genre.localizedCaseInsensitiveContains(g) }
        }
        if !viewModel.filterTag.isEmpty {
            let t = viewModel.filterTag
            list = list.filter { book in
                book.tags.contains { $0.caseInsensitiveCompare(t) == .orderedSame }
            }
        }
        switch viewModel.sortMode {
        case .dateAddedNewest:
            list.sort { $0.addedAt > $1.addedAt }
        case .dateAddedOldest:
            list.sort { $0.addedAt < $1.addedAt }
        case .titleAZ:
            list.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .authorAZ:
            list.sort { $0.author.localizedCaseInsensitiveCompare($1.author) == .orderedAscending }
        case .readFirst:
            list.sort { one, two in
                if one.isRead != two.isRead { return one.isRead && !two.isRead }
                return one.addedAt > two.addedAt
            }
        }
        return list
    }

    private var shelfGenres: [String] {
        let set = Set(store.shelfBooks.map { $0.genre.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty })
        return set.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    private var shelfTags: [String] {
        var set = Set<String>()
        for book in store.shelfBooks {
            for tag in book.tags {
                let t = tag.trimmingCharacters(in: .whitespacesAndNewlines)
                if !t.isEmpty { set.insert(t) }
            }
        }
        return set.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    private var activeFilterChips: [FilterChip] {
        var chips: [FilterChip] = []
        if viewModel.readFilter != .all {
            chips.append(FilterChip(id: "status", label: viewModel.readFilter.title) {
                viewModel.readFilter = .all
            })
        }
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

    private var readCount: Int { store.shelfBooks.filter(\.isRead).count }
    private var unreadCount: Int { store.shelfBooks.count - readCount }

    var body: some View {
        AppNavigationScreen {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if store.shelfBooks.isEmpty {
                        emptyState
                    } else {
                        bookList
                    }
                }

                fabButton
            }
            .navigationTitle("My Bookshelf")
            .navigationBarTitleDisplayMode(.inline)
            .appToolbarChrome()
            .searchable(text: $viewModel.searchText, prompt: "Search title, author, tags…")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    filterMenu
                }
            }
            .onAppear { store.touchBookshelfOpened() }
            .sheet(isPresented: $viewModel.isPresentingEditor) { editorSheet }
            .successCheckmark(trigger: $showSuccessCheck)
        }
    }

    private var fabButton: some View {
        Button {
            FeedbackEffects.buttonTap()
            viewModel.beginAdd()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.appOnPrimary)
                .frame(width: 58, height: 58)
                .background(Circle().fill(AppGradients.tabSelected))
                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                .compositingGroup()
                .appDepthShadow(.floating)
        }
        .scaleEffect(fabPulse)
        .padding(.trailing, 20)
        .padding(.bottom, 20)
        .accessibilityLabel("Add Book")
    }

    private var filterMenu: some View {
        Menu {
            Section("Sort") {
                ForEach(ShelfSortMode.allCases) { mode in
                    Button {
                        FeedbackEffects.buttonTap()
                        viewModel.sortMode = mode
                    } label: {
                        Label(mode.title, systemImage: viewModel.sortMode == mode ? "checkmark" : "arrow.up.arrow.down")
                    }
                }
            }
            Section("Status") {
                ForEach(ReadStatusFilter.allCases) { f in
                    Button {
                        FeedbackEffects.buttonTap()
                        viewModel.readFilter = f
                    } label: {
                        Label(f.title, systemImage: viewModel.readFilter == f ? "checkmark" : "circle")
                    }
                }
            }
            Section("Genre") {
                Button("All genres") { viewModel.filterGenre = "" }
                ForEach(shelfGenres, id: \.self) { g in
                    Button(g) { viewModel.filterGenre = g }
                }
            }
            Section("Tag") {
                Button("All tags") { viewModel.filterTag = "" }
                ForEach(shelfTags, id: \.self) { t in
                    Button(t) { viewModel.filterTag = t }
                }
            }
        } label: {
            Image(systemName: activeFilterChips.isEmpty ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color.appPrimary)
                .frame(minWidth: 44, minHeight: 44)
        }
    }

    private var editorSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    AppFormSection(title: "Details") {
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
                        AppFormTextField(placeholder: "Genre (color stripe)", text: $viewModel.genreText)
                        AppFormToggleRow(title: "Mark as read", isOn: $viewModel.markRead)
                    }

                    AppFormSection(title: "Series") {
                        AppFormTextField(placeholder: "Series name", text: $viewModel.seriesNameText)
                        AppFormTextField(placeholder: "Volume or #", text: $viewModel.seriesVolumeText)
                    }

                    AppFormSection(title: "Tags") {
                        AppFormTextField(placeholder: "Comma-separated tags", text: $viewModel.tagsText)
                    }

                    AppFormSection(title: "Notes") {
                        AppFormNotesEditor(text: $viewModel.notesText)
                    }
                }
                .padding(16)
            }
            .appFormScreenBackground()
            .navigationTitle(viewModel.editingBook == nil ? "Add Book" : "Edit Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        FeedbackEffects.buttonTap()
                        viewModel.isPresentingEditor = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveTapped() }
                        .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var emptyState: some View {
        ScrollView {
            AppEmptyState(
                systemImage: "books.vertical.fill",
                title: "No books yet",
                message: "Start building your shelf by adding titles you own or plan to read.",
                actionTitle: "Add first book",
                action: {
                    FeedbackEffects.buttonTap()
                    viewModel.beginAdd()
                }
            )
        }
    }

    private var statsStrip: some View {
        HStack(spacing: 10) {
            AppStatPill(title: "Total", value: "\(store.shelfBooks.count)")
            AppStatPill(title: "Read", value: "\(readCount)", tint: .appAccent)
            AppStatPill(title: "Unread", value: "\(unreadCount)", tint: .appTextSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var bookList: some View {
        List {
            Section {
                statsStrip
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            if !activeFilterChips.isEmpty {
                Section {
                    FilterChipBar(chips: activeFilterChips) {
                        viewModel.readFilter = .all
                        viewModel.filterGenre = ""
                        viewModel.filterTag = ""
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }

            if displayedBooks.isEmpty {
                Section {
                    Text("No matches for current filters.")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .listRowBackground(Color.clear)
                }
            } else {
                Section {
                    ForEach(displayedBooks) { book in
                        ShelfBookCell(
                            book: book,
                            highlighted: store.lastAddedShelfBookId == book.id
                        )
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .scaleEffect(store.lastAddedShelfBookId == book.id ? 1.02 : 1)
                        .animation(.spring(response: 0.4, dampingFraction: 0.65), value: store.lastAddedShelfBookId)
                        .onTapGesture {
                            FeedbackEffects.buttonTap()
                            viewModel.beginEdit(book)
                        }
                        .contextMenu {
                            Button(book.isRead ? "Mark Unread" : "Mark Read") {
                                toggleRead(book)
                            }
                            Button("Edit") { viewModel.beginEdit(book) }
                            Button(role: .destructive) {
                                store.deleteShelfBook(id: book.id)
                            } label: {
                                Text("Delete")
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                store.deleteShelfBook(id: book.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button { toggleRead(book) } label: {
                                Label(book.isRead ? "Unread" : "Read", systemImage: book.isRead ? "book.closed" : "checkmark.circle")
                            }
                            .tint(Color.appPrimary)
                        }
                    }
                } header: {
                    AppSectionHeader(
                        title: "Your shelf",
                        subtitle: "\(displayedBooks.count) shown · \(viewModel.sortMode.title)",
                        trailing: nil
                    )
                    .textCase(nil)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 0, trailing: 16))
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func toggleRead(_ book: ShelfBook) {
        FeedbackEffects.saveOrComplete()
        var updated = book
        updated.isRead.toggle()
        store.updateShelfBook(updated)
    }

    private func saveTapped() {
        guard viewModel.validate() else { return }
        FeedbackEffects.saveOrComplete()
        let tags = TagParsing.tags(fromCommaSeparated: viewModel.tagsText)
        if let existing = viewModel.editingBook {
            var updated = existing
            updated.title = viewModel.titleText.trimmingCharacters(in: .whitespacesAndNewlines)
            updated.author = viewModel.authorText.trimmingCharacters(in: .whitespacesAndNewlines)
            updated.genre = viewModel.genreText.trimmingCharacters(in: .whitespacesAndNewlines)
            updated.notes = viewModel.notesText
            updated.tags = tags
            updated.seriesName = viewModel.seriesNameText.trimmingCharacters(in: .whitespacesAndNewlines)
            updated.seriesVolume = viewModel.seriesVolumeText.trimmingCharacters(in: .whitespacesAndNewlines)
            updated.isRead = viewModel.markRead
            store.updateShelfBook(updated)
            FeedbackEffects.successPing()
            showSuccessCheck = true
        } else {
            let newBook = ShelfBook(
                id: UUID(),
                title: viewModel.titleText.trimmingCharacters(in: .whitespacesAndNewlines),
                author: viewModel.authorText.trimmingCharacters(in: .whitespacesAndNewlines),
                isRead: viewModel.markRead,
                genre: viewModel.genreText.trimmingCharacters(in: .whitespacesAndNewlines),
                notes: viewModel.notesText,
                tags: tags,
                seriesName: viewModel.seriesNameText.trimmingCharacters(in: .whitespacesAndNewlines),
                seriesVolume: viewModel.seriesVolumeText.trimmingCharacters(in: .whitespacesAndNewlines),
                addedAt: Date()
            )
            guard store.addShelfBook(newBook) else { return }
            FeedbackEffects.playSystemSound(1001)
            withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) { fabPulse = 1.08 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) { fabPulse = 1 }
            }
            showSuccessCheck = true
        }
        viewModel.isPresentingEditor = false
    }
}
