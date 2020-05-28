import FluentPostgreSQL

extension User: Migration {
    typealias Database = PostgreSQLDatabase
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.username)
        }
    }
}

extension Category: Migration {
    typealias Database = PostgreSQLDatabase
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.name)
            builder.field(for: \.slug)
            builder.unique(on: \.slug)
            builder.field(for: \.description, type: .varchar(Category.descriptionLength))
            builder.field(for: \.logo)
            builder.field(for: \.createdAt, type: .timestamptz(1184))
            builder.field(for: \.updatedAt, type: .timestamptz(1184))
        }
    }
}

extension Post: Migration {
    typealias Database = PostgreSQLDatabase
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: idKey)
            builder.field(for: \.author)
            builder.field(for: \.title, type: .varchar(Post.titleLength))
            builder.field(for: \.text)
            builder.field(for: \.textHtml)
            builder.field(for: \.preview)
            builder.field(for: \.category)
            builder.field(for: \.createdAt, type: .timestamptz(1184))
            builder.field(for: \.updatedAt, type: .timestamptz(1184))
            builder.field(for: \.publishedAt, type: .timestamptz(1184))
            builder.field(for: \.isPublished, type: .bool)
            builder.field(for: \.slug)
            builder.field(for: \.lang)
            builder.unique(on: \.slug)
            builder.reference(from: \.author, to: \User.id, onUpdate: .restrict, onDelete: .cascade)
            builder.reference(from: \.category, to: \Category.id, onUpdate: .restrict, onDelete: .cascade)
        }
    }
}
