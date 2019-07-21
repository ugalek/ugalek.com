import Vapor

extension Request {
    var acceptLanguage: String {
        get {
            guard let acceptLanguage = self.http
                .headers
                .firstValue(name: .acceptLanguage)?
                .split(separator: ",")
                .first else {
                    return "en"
            }
            switch acceptLanguage {
            case "en-US", "en-us": return "en"
            case "fr-FR", "fr-fr": return "fr_FR"
            case "ru-RU", "ru-ru": return "ru_RU"
            default: return "en"
            }
        }
    }
}
