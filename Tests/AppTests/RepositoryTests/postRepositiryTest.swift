@testable import App

import FluentPostgreSQL
import Vapor
import XCTest

final class PostRepositoryTest: XCTestCase {
    func testPosts() throws {
        let app = try Application.testable()
        let dbConnection = try app.newConnection(to: .psql).wait()
        
        let tesTitle = String.createRandom(length: 15)
        let testSlug = tesTitle.slugify()
        
        // Save new post
        let user = User(id: nil,
                        username: String.createRandom(length: 15),
                        password: String.createRandom(length: 15),
                        name: String.createRandom(length: 15),
                        isAdmin: false)
        let savedUser = try user.save(on: dbConnection).wait()
        
        let category = Category(id: nil,
                                name: String.createRandom(length: 15),
                                slug: String.createRandom(length: 15),
                                description: String.createRandom(length: 15),
                                logo: "Path")
        let savedCategory = try category.save(on: dbConnection).wait()
        
        let post = Post(id: nil,
                        author: savedUser.id!,
                        title: tesTitle,
                        text: String.createRandom(length: 15),
                        textHtml: String.createRandom(length: 15),
                        preview: String.createRandom(length: 15),
                        categoryID: savedCategory.id,
                        publishedAt: Date(),
                        slug: testSlug,
                        lang: "EN",
                        isPublished: true)
        
        let savedPost = try post.save(on: dbConnection).wait()
        
        XCTAssertEqual(savedPost.slug, testSlug)
        XCTAssertNotNil(savedPost.id)
        
        // GET all posts
        var reqPosts = HTTPRequest(method: .GET, url: URL(string: "/posts")!)
        var wrappedRequest = Request(http: reqPosts, using: app)
        let posts = try PostRepository().findAllPosts(on: wrappedRequest).wait()
        
        XCTAssertNotNil(posts.count)
        
        // GET all post with range
        reqPosts = HTTPRequest(method: .GET, url: URL(string: "/posts?p=1")!)
        wrappedRequest = Request(http: reqPosts, using: app)
        let rangeOfPosts = try PostRepository().findAll(on: wrappedRequest).wait()
        
        XCTAssertNotNil(rangeOfPosts.count)
        
        // Find post by searching string
        let findPost = try PostRepository().findPost(on: wrappedRequest, searchString: savedPost.title).wait()
        
        XCTAssertNotNil(findPost.count)
        XCTAssertEqual(findPost[0].post.slug, testSlug)
        XCTAssertEqual(findPost[0].category.slug, savedCategory.slug)
        
        
        // Get post by ID
        let postID = try PostRepository().getByID(on: wrappedRequest, postID: savedPost.id!).wait()
        XCTAssertEqual(postID.id, savedPost.id!)
        
        // Get post by slug
        let postSlug = try PostRepository().getBySlug(on: wrappedRequest, slug: savedPost.slug).wait()
        XCTAssertNotNil(postSlug)
        XCTAssertEqual(postSlug?.post.slug, testSlug)
        XCTAssertEqual(postSlug?.category.slug, savedCategory.slug)
        
        dbConnection.close()
    }
}
