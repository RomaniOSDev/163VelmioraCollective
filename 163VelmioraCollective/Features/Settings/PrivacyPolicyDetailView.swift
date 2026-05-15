import Foundation
import SwiftUI

struct PrivacyPolicyDetailView: View {
    @Environment(\.dismiss) private var dismiss
    private let markdownText: String

    init(markdownText: String) {
        self.markdownText = markdownText
    }

    private var privacyAttributed: AttributedString {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .full)
        if let parsed = try? AttributedString(markdown: markdownText, options: options) {
            return parsed
        }
        return AttributedString(markdownText)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(privacyAttributed)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .tint(Color.appPrimary)
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.leading)
                    .textSelection(.enabled)
            }
            .appFormScreenBackground()
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .appToolbarChrome()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        FeedbackEffects.buttonTap()
                        dismiss()
                    }
                    .foregroundStyle(Color.appPrimary)
                }
            }
        }
    }
}

enum PrivacyPolicyLoader {
    static func load() -> String {
        guard let url = Bundle.main.url(forResource: "privacy_policy", withExtension: "md") else {
            return "# Privacy Policy\nContent unavailable."
        }
        guard let data = try? Data(contentsOf: url), let text = String(data: data, encoding: .utf8) else {
            return "# Privacy Policy\nContent unavailable."
        }
        return text
    }
}
