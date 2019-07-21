import Vapor

final class DateTag: TagRenderer {
    init() {}
    
    func render(tag: TagContext) throws -> EventLoopFuture<TemplateData> {
        try tag.requireNoBody()
        try tag.requireParameterCount(1)
        guard let baseDate = tag.parameters[0].double else {
            throw tag.error(reason: "Specified values have to be doubles/time intervals")
        }
        return tag.container.future(.string(formatDoubleToString(date: baseDate)))
    }
}
