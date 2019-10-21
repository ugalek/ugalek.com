import Lingo
import Vapor

final class KaniotteController {
    func index(request: Request) throws -> Future<View> {
        do {
            let lang = getLocale(session: try request.session())

            if lang == "ru_RU" {
                return try request.view().render("kaniotte_ru")
            } else if lang == "fr_FR" {
                return try request.view().render("kaniotte_fr")
            } else {
                return try request.view().render("kaniotte_en")
            }
        } catch {
            print("Cannot get base lingo data")
        }

        return try request.view().render("kaniotte_en")
    }

    func setLanguage(request: Request) throws -> Future<Response> {
        let session = try request.session()
        if let lang = request.query[String.self, at: "l"] {
            session["lang"] = lang
        } else {
            session["lang"] = "en"
        }
        return Future.map(on: request) { request.redirect(to: "/") }
    }
}
