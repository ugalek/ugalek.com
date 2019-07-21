import Lingo
import Vapor

public func getAuthUser(session: Session) -> AuthUser {
    if session["username"] != nil {
        return AuthUser(username: session["username"] ?? "", isAdmin: NSString(string: session["isAdmin"]!).boolValue)
    }

    return AuthUser(username: "", isAdmin: false)
}

public func getLocale(session: Session) -> String {
    if session["lang"] == nil {
        return "en"
    }

    switch session["lang"] {
    case "en": return "en"
    case "fr": return "fr_FR"
    case "ru": return "ru_RU"
    default: return "en"
    }
}

public func getRandomTitle() -> String {
    return "/uploads/ptitle\(Int.random(in: 1 ... 5)).jpg"
}

private func buildURL(path: URL) -> String {
    var components = URLComponents()
    components.scheme = "http"
    if String(Host.current().address!) == "127.0.0.1" {
        components.host = "localhost"
    } else {
        components.host = "ugalek.com"
    }
    
    components.path = path.absoluteString
    
    return components.url!.absoluteString
}

func getPathToSocial(on request: Request) -> [PathToSocial] {
    let url = buildURL(path: request.http.url)
    return [
        PathToSocial(icon: "fab fa-twitter", color: "blue-text", path: "http://twitter.com/intent/tweet?text=\(url)"),
        PathToSocial(icon: "fab fa-facebook", color: "indigo-text", path: "http://www.facebook.com/sharer/sharer.php?u=\(url)"),
        PathToSocial(icon: "fab fa-vk", color: "light-blue-text text-darken-4", path: "http://vkontakte.ru/share.php?url=\(url)")
    ]
}

func getBaseView(on request: Request, title: String) -> BaseMenuView {
    do {
        let lingo = try request.make(Lingo.self)
        let lang = getLocale(session: try request.session())

        return BaseMenuView(titleString: lingo.localize(title, locale: lang),
                            footerString: lingo.localize("footer", locale: lang),
                            titleConnect: lingo.localize("title.connect", locale: lang),
                            navMenu: getNavMenu(on: request),
                            menuSearch: lingo.localize("menu.search", locale: lang))
    } catch {
        print("Cannot get base lingo data")
    }
    
    return BaseMenuView(titleString: "Ugalek.com", footerString: "", titleConnect: "Connect", navMenu: [NavMenu](), menuSearch: "Search")
}

func getNavMenu(on request: Request) -> [NavMenu] {
    var baseLinks = [NavMenu]()

    do {
        let lingo = try request.make(Lingo.self)
        let lang = getLocale(session: try request.session())

        baseLinks.append(NavMenu(active: true, name: lingo.localize("menu.home", locale: lang), path: "/"))
        baseLinks.append(NavMenu(active: false, name: lingo.localize("menu.articles", locale: lang), path: "/posts"))

        let authUser = getAuthUser(session: try request.session())

        if authUser.username != "" {
            baseLinks.append(NavMenu(active: false, name: authUser.username, path: "/profile"))
        }

        if authUser.isAdmin {
            baseLinks.append(NavMenu(active: false, name: lingo.localize("menu.users", locale: lang), path: "/users"))
            baseLinks.append(NavMenu(active: false, name: lingo.localize("menu.categories", locale: lang), path: "/categories"))
        }

    } catch {
        print("Cannot get lingo profile or auth user")
    }

    return baseLinks
}

func getPageNumper(on request: Request) -> Int {
    if let page = request.query[Int.self, at: "p"] {
        return page
    } else {
        return 1
    }
}

func rangeOfPages(page: Int) -> (min: Int, max: Int) {
    let maxNum = (page * 3) - 1
    let minNum = maxNum - 2
    return (minNum, maxNum)
}

func formatStringToDate(date: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy"
    dateFormatter.timeZone = TimeZone.current
    return dateFormatter.date(from: date) ?? Date()
}

func formatDoubleToString(date: Double) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy"
    dateFormatter.timeZone = TimeZone.current
    return dateFormatter.string(from: Date(timeIntervalSince1970: date))
}

struct PathToSocial: Content {
    var icon: String
    var color: String
    var path: String

    init(icon: String, color: String, path: String) {
        self.icon = icon
        self.color = color
        self.path = path
    }
}

struct NavMenu: Content {
    var active: Bool
    var name: String
    var path: String

    init(active: Bool, name: String, path: String) {
        self.active = active
        self.name = name
        self.path = path
    }
}

struct BaseMenuView: Content {
    var titleString: String
    var footerString: String
    var titleConnect: String
    var navMenu: [NavMenu]
    var menuSearch: String

    init(titleString: String, footerString: String, titleConnect: String, navMenu: [NavMenu], menuSearch: String) {
        self.titleString = titleString
        self.footerString = footerString
        self.titleConnect = titleConnect
        self.navMenu = navMenu
        self.menuSearch = menuSearch
    }
}
