@testable import App

import FluentPostgreSQL
import Vapor
import XCTest

final class UserRepositoryTest: XCTestCase {
    func testUsers() throws {
        let app = try Application.testable()
        let dbConnection = try app.newConnection(to: .psql).wait()
        
        let testUsername = String.createRandom(length: 15)
        let testPassword = String.createRandom(length: 10)
        let testName = String.createRandom(length: 15)
        
    
        // GET all users
        let reqUsers = HTTPRequest(method: .GET, url: URL(string: "/users")!)
        let wrappedRequest = Request(http: reqUsers, using: app)
        let usersB = try UserRepository().findAll(on: wrappedRequest).wait().count

        // Save new user
        let user = User(id: nil, username: testUsername, password: testPassword, name: testName, isAdmin: false)
        let savedUser = try user.save(on: dbConnection).wait()

        XCTAssertEqual(savedUser.name, testName)
        XCTAssertEqual(savedUser.username, testUsername)
        XCTAssertNotNil(savedUser.id)

        let usersA = try UserRepository().findAll(on: wrappedRequest).wait()

        XCTAssertEqual(usersA.count, usersB + 1)
        XCTAssertEqual(usersA[usersB].name, testName)
        XCTAssertEqual(usersA[usersB].username, testUsername)
        XCTAssertEqual(usersA[usersB].id, savedUser.id)

        //****************************
//        let responder = try app.make(Responder.self)
//        let users = HTTPRequest(method: .GET, url: URL(string: "/users")!)
//        let wrappedRequest = Request(http: users, using: app)
//        let response = try responder.respond(to: wrappedRequest).wait()
//        let data = response.http.body.data
//        let person = try JSONDecoder().decode([User].self, from: data!)
        
        // Shall not allow posts without authorization
        // XCTAssertEqual(response.http.status, HTTPResponseStatus.unauthorized)
        
        dbConnection.close()
    }
}
