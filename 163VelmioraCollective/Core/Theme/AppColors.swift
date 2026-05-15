import SwiftUI

extension Color {
    static let appBackground = Color("AppBackground")
    static let appSurface = Color("AppSurface")
    static let appPrimary = Color("AppPrimary")
    static let appAccent = Color("AppAccent")
    static let appTextPrimary = Color("AppTextPrimary")
    static let appTextSecondary = Color("AppTextSecondary")

    /// Тёплый акцент фона (золотое свечение сверху).
    static let appBackgroundGlow = Color.appPrimary.opacity(0.14)

    /// Холодный акцент фона (бирюзовое свечение снизу).
    static let appBackgroundCool = Color.appAccent.opacity(0.10)

    /// Текст/иконки на золотых кнопках и вкладках.
    static let appOnPrimary = Color(red: 0.12, green: 0.14, blue: 0.20)
}
