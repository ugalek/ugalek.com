import Lingo
import Vapor

final class HomeController {
    func index(request: Request) throws -> Future<View> {
        let ctx = HomeView(
            baseView: getBaseView(on: request, title: "title.home")
        )

        do {
            let lang = getLocale(session: try request.session())

            if lang == "ru_RU" {
                return try request.view().render("home_ru", ctx)
            } else if lang == "fr_FR" {
                return try request.view().render("home_fr", ctx)
            }
        } catch {
            print("Cannot get base lingo data")
        }

        return try request.view().render("home", ctx)
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

struct HomeView: Encodable {
    var baseView: BaseMenuView
}
