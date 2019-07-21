@testable import App

import FluentPostgreSQL
import Vapor
import XCTest
import Slugify

final class CategoryRepositoryTest: XCTestCase {
    func testCategories() throws {
        let app = try Application.testable()
        let dbConnection = try app.newConnection(to: .psql).wait()

        let testName = String.createRandom(length: 15)
        let testSlug = testName.slugify()
        let testDescription = String.createRandom(length: 15)

        // GET all categories
        let reqCategories = HTTPRequest(method: .GET, url: URL(string: "/categories")!)
        let wrappedRequest = Request(http: reqCategories, using: app)
        let categoriesB = try CategoryRepository().findAll(on: wrappedRequest).wait().count

        // Save new category
        let category = Category(id: nil, name: testName, slug: testSlug, description: testDescription, logo: "Path")
        let savedCategory = try category.save(on: dbConnection).wait()

        XCTAssertEqual(savedCategory.name, testName)
        XCTAssertEqual(savedCategory.slug, testSlug)
        XCTAssertNotNil(savedCategory.id)

        let categoriesA = try CategoryRepository().findAll(on: wrappedRequest).wait()

        XCTAssertEqual(categoriesA.count, categoriesB + 1)
        XCTAssertEqual(categoriesA[categoriesB].name, testName)
        XCTAssertEqual(categoriesA[categoriesB].slug, testSlug)
        XCTAssertEqual(categoriesA[categoriesB].id, savedCategory.id)

        // Get category by ID
        let categoryID = try CategoryRepository().getByID(on: wrappedRequest, categoryID: savedCategory.id!).wait()
        XCTAssertEqual(categoryID.id, savedCategory.id!)

        // Get category by slug
        let categorySlug = try CategoryRepository().getBySlug(on: wrappedRequest, categorySlug: savedCategory.slug).wait()
        XCTAssertEqual(categorySlug?.slug, savedCategory.slug)

        //Get cards of categories
        let categoriesCards = try CategoryRepository().getCategories(on: wrappedRequest).wait()
        XCTAssertNotNil(categoriesCards.count)

        for i in 0...categoriesCards.count-1 {
            XCTAssertLessThanOrEqual(categoriesCards[i].categoryArr.count, 3)
        }

        dbConnection.close()
    }
}
