import FluentPostgreSQL
import Foundation
import Vapor

protocol DatabaseModel: PostgreSQLModel, Parameter {
    var createdAt: Date? { get set }
    var updatedAt: Date? { get set }
}

extension DatabaseModel {
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
}
