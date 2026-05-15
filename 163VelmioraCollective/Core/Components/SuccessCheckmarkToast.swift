import SwiftUI

struct SuccessCheckmarkToast: View {
    @Binding var isVisible: Bool

    var body: some View {
        ZStack {
            if isVisible {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isVisible)
    }
}

struct SuccessCheckmarkHost: ViewModifier {
    @Binding var trigger: Bool

    @State private var visible = false

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .center) {
                SuccessCheckmarkToast(isVisible: $visible)
            }
            .onChange(of: trigger) { newValue in
                guard newValue else { return }
                visible = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    visible = false
                    trigger = false
                }
            }
    }
}

extension View {
    func successCheckmark(trigger: Binding<Bool>) -> some View {
        modifier(SuccessCheckmarkHost(trigger: trigger))
    }
}
