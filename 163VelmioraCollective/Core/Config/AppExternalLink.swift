import Foundation

/// Внешние ссылки приложения (Privacy, Terms, Support и т.д.).
enum AppExternalLink {
    case privacyPolicy
    case termsOfUse
    
    
    var urlString: String {
        switch self {
        case .privacyPolicy:
            return "https://velmioracollective.com/privacy-policy.html"
        case .termsOfUse:
            return "https://velmioracollective.com/support.html"
            
        }
    }
        
        var url: URL? {
            URL(string: urlString)
        }
        
        var settingsTitle: String {
            switch self {
            case .privacyPolicy:
                return "Privacy"
            case .termsOfUse:
                return "Terms"
                
            }
        }
            
            var systemImage: String {
                switch self {
                case .privacyPolicy:
                    return "hand.raised.fill"
                case .termsOfUse:
                    return "doc.text.fill"
                    
                }
            }
        }
    

