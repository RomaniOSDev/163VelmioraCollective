import SwiftUI

struct PrimaryProminentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(Color.appOnPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(
                shape.fill(configuration.isPressed ? AppGradients.primaryButtonPressed : AppGradients.primaryButton)
            )
            .overlay(shape.stroke(Color.white.opacity(configuration.isPressed ? 0.08 : 0.18), lineWidth: 1))
            .compositingGroup()
            .appDepthShadow(configuration.isPressed ? .soft : .card)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

struct SecondarySurfaceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(Color.appTextPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 44)
            .appDepthCard(cornerRadius: 14, shadow: configuration.isPressed ? .soft : .card)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}
