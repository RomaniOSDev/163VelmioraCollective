import AudioToolbox
import UIKit

enum FeedbackEffects {
    private static let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private static let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private static let notification = UINotificationFeedbackGenerator()

    static func buttonTap() {
        lightImpact.prepare()
        lightImpact.impactOccurred()
    }

    static func saveOrComplete() {
        mediumImpact.prepare()
        mediumImpact.impactOccurred()
    }

    static func successPing() {
        notification.prepare()
        notification.notificationOccurred(.success)
        AudioServicesPlaySystemSound(1057)
    }

    static func achievementUnlocked() {
        notification.prepare()
        notification.notificationOccurred(.success)
    }

    static func invalidInput() {
        notification.prepare()
        notification.notificationOccurred(.warning)
    }

    static func playSystemSound(_ soundId: SystemSoundID) {
        AudioServicesPlaySystemSound(soundId)
    }
}
