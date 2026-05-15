import StoreKit
import SwiftUI
import UIKit

struct SettingsTabView: View {
    @EnvironmentObject private var store: LibraryAppStorage
    @StateObject private var viewModel = SettingsTabViewModel()
    @State private var reminderSheet = false
    @State private var editingReminderId: UUID?
    @State private var reminderDraft = InAppReminder(title: "", detail: "", dueDate: Date())
    @State private var reminderTitleError = ""

    private var versionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return version ?? "1.0"
    }

    private var sortedReminders: [InAppReminder] {
        store.inAppReminders.sorted { $0.dueDate < $1.dueDate }
    }

    private var calendar: Calendar { Calendar.current }

    var body: some View {
        AppNavigationScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    statsCard
                    remindersCard
                    legalCard

                    Button(role: .destructive) {
                        FeedbackEffects.buttonTap()
                        viewModel.showResetConfirm = true
                    } label: {
                        Text("Reset All Data")
                            .font(.headline.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.red.opacity(0.45), lineWidth: 1)
                            )
                    }

                    Text("Version \(versionString)")
                        .font(.footnote)
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .appToolbarChrome()
            .sheet(isPresented: $reminderSheet) {
                reminderEditorSheet
            }
            .alert("Reset All Data", isPresented: $viewModel.showResetConfirm) {
                Button("Cancel", role: .cancel) { FeedbackEffects.buttonTap() }
                Button("Reset", role: .destructive) {
                    FeedbackEffects.saveOrComplete()
                    store.resetAllData()
                    FeedbackEffects.successPing()
                }
            } message: {
                Text("This permanently clears books, logs, goals, reminders, pins, streaks, and achievements on this device.")
            }
        }
    }

    private var statsCard: some View {
        AppSurfaceCard {
            VStack(alignment: .leading, spacing: 10) {
                AppSectionHeader(title: "Activity", systemImage: "waveform.path.ecg")
                HStack(spacing: 10) {
                    AppStatPill(title: "Streak", value: "\(store.streakDays)d", tint: .appAccent)
                    AppStatPill(title: "Sessions", value: "\(store.totalSessionsCompleted)")
                }
                AppMetricRow(label: "Entries created", value: "\(store.itemsCreated + store.readingLog.count)", icon: "square.and.pencil")
                AppMetricRow(label: "Minutes used", value: "\(store.totalMinutesUsed)", icon: "clock")
            }
        }
    }

    private var remindersCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                AppSectionHeader(title: "In-app reminders", subtitle: "No push — shown when you open the app", systemImage: "bell.badge")
                Spacer()
                Button {
                    FeedbackEffects.buttonTap()
                    beginNewReminder()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color.appPrimary)
                }
                .accessibilityLabel("Add reminder")
            }

            if sortedReminders.isEmpty {
                AppSurfaceCard {
                    AppEmptyState(
                        systemImage: "bell.slash",
                        title: "No reminders",
                        message: "Add a date-based reminder for your next reading session.",
                        actionTitle: "Add reminder",
                        action: beginNewReminder
                    )
                    .padding(.vertical, 8)
                }
            } else {
                ForEach(sortedReminders) { item in
                    ReminderCell(
                        reminder: item,
                        isOverdue: calendar.startOfDay(for: item.dueDate) <= calendar.startOfDay(for: Date()),
                        onEdit: { beginEditReminder(item) },
                        onDelete: {
                            FeedbackEffects.buttonTap()
                            store.deleteReminder(id: item.id)
                        }
                    )
                }
            }
        }
    }

    private var legalCard: some View {
        AppSurfaceCard {
            VStack(spacing: 0) {
                AppSectionHeader(title: "Legal & feedback", systemImage: "shield.lefthalf.filled")
                    .padding(.bottom, 8)

                SettingsNavRow(title: "Rate Us", systemImage: "star.fill", tint: .appAccent) {
                    rateApp()
                }
                settingsDivider
                SettingsNavRow(
                    title: AppExternalLink.privacyPolicy.settingsTitle,
                    systemImage: AppExternalLink.privacyPolicy.systemImage
                ) {
                    openExternalLink(.privacyPolicy)
                }
                settingsDivider
                SettingsNavRow(
                    title: AppExternalLink.termsOfUse.settingsTitle,
                    systemImage: AppExternalLink.termsOfUse.systemImage
                ) {
                    openExternalLink(.termsOfUse)
                }
            }
        }
    }

    private var settingsDivider: some View {
        Divider()
            .opacity(0.2)
            .padding(.leading, 54)
    }

    private var reminderEditorSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    AppFormSection(title: "Reminder") {
                        AppFormTextField(placeholder: "Title", text: $reminderDraft.title)
                        if !reminderTitleError.isEmpty {
                            AppFormErrorText(message: reminderTitleError)
                        }
                        AppFormTextField(placeholder: "Notes (optional)", text: $reminderDraft.detail)
                        AppFormDatePicker(title: "Due date", date: $reminderDraft.dueDate)
                    }
                }
                .padding(16)
            }
            .appFormScreenBackground()
            .navigationTitle(editingReminderId == nil ? "New reminder" : "Edit reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        FeedbackEffects.buttonTap()
                        reminderSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveReminderDraft() }
                        .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func beginNewReminder() {
        editingReminderId = nil
        reminderDraft = InAppReminder(title: "", detail: "", dueDate: Date())
        reminderTitleError = ""
        reminderSheet = true
    }

    private func beginEditReminder(_ item: InAppReminder) {
        FeedbackEffects.buttonTap()
        editingReminderId = item.id
        reminderDraft = item
        reminderTitleError = ""
        reminderSheet = true
    }

    private func saveReminderDraft() {
        let title = reminderDraft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if title.isEmpty {
            reminderTitleError = "Title is required."
            FeedbackEffects.invalidInput()
            return
        }
        reminderTitleError = ""
        FeedbackEffects.saveOrComplete()
        let id = editingReminderId ?? reminderDraft.id
        let saved = InAppReminder(
            id: id,
            title: title,
            detail: reminderDraft.detail,
            dueDate: reminderDraft.dueDate,
            linkedShelfBookId: reminderDraft.linkedShelfBookId
        )
        store.upsertReminder(saved)
        FeedbackEffects.playSystemSound(1104)
        reminderSheet = false
    }

    private func openExternalLink(_ link: AppExternalLink) {
        FeedbackEffects.buttonTap()
        guard let url = link.url else { return }
        UIApplication.shared.open(url)
    }

    private func rateApp() {
        FeedbackEffects.buttonTap()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
