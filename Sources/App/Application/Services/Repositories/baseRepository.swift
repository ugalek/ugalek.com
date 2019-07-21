import FluentPostgreSQL
import Vapor

struct BaseRepository {
    
    func notFoundErr(reason r: String) -> AbortError {
        return Abort(.notFound, reason: r + " not found")
    }
    
    func getPages(on request: Request, t futureTotalPages: Future<Int>, p pathName: String, s searchString: String = "") throws -> Future<[PaginationLinks]> {
        var arrayOfPages = [PaginationLinks]()
        let page = getPageNumper(on: request)
        
        if page == 1 {
            arrayOfPages.append(PaginationLinks(
                path: "#",
                style: "page-item disabled",
                page: "<<")
            )
        }
        
        return futureTotalPages.map(to: [PaginationLinks].self) { (nums) -> [PaginationLinks] in
            let totalPages = max(1, Int(ceil(Double(nums) / Double(3))))
            
            for i in 1...totalPages {
                if page != 1, i == 1 {
                    arrayOfPages.append(PaginationLinks(
                        path: "/\(pathName)?p=\(page - 1)" + searchString,
                        style: "page-item",
                        page: "<<")
                    )
                }
                
                arrayOfPages.append(PaginationLinks(
                    path: "/\(pathName)?p=\(i)" + searchString,
                    style: "page-item \(page == i ? " active" : "")",
                    page: String(i))
                )
            }
            arrayOfPages.append(PaginationLinks(
                path: "/\(pathName)?p=\(page == totalPages ? page : page + 1)" + searchString,
                style: "page-item \(page == totalPages ? "disabled" : "")",
                page: ">>")
            )
            
            return arrayOfPages
        }
    }
}
