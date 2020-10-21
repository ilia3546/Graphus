//
//  GraphusTests.swift
//  GraphusTests
//
//  Created by Ilya Kharlamov on 07/05/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import XCTest
import Graphus

class GraphusTests: XCTestCase {

    struct SampleModel: Codable, Reflectable {
        var testVar: String
    }
    
    var client: GraphusClient = {
        let url = URL(string: "http://localhost:8080/graphql")!
        return GraphusClient(url: url, configuration: .default)
    }()
    
    func testTestReflectableModel() {
        let modelQuery = Query("test", model: TestReflectableModel.self)
        XCTAssertEqual(modelQuery.fieldString, "test{nested{nestedVar},testVar,nested{nestedVarAnother}}")
    }
    
    func testCustomReflectableQuery() {
        let modelQuery = Query("test", fields: [\TestReflectableModel.nested.nestedVar, \TestReflectableModel.testVar])
        XCTAssertEqual(modelQuery.fieldString, "test{nested{nestedVar},testVar}")
    }
    
    func testCustomQuery() {
        let query = Query("authors", arguments: ["first":10], fields: ["firstName", "secondName"])
        XCTAssertEqual(query.fieldString, "authors(first: 10){firstName,secondName}")
    }
    
    func testSend() {
        let expectation = XCTestExpectation()
        let query = Query("authors", arguments: ["first":10], fields: ["firstName", "secondName"])
        self.client.request(.query, query: query).send { result in
            switch result{
            case .failure(let error):
            XCTAssertNotNil(error)
            case .success(let response):
            XCTAssertNotNil(response.data)
            XCTAssertNotNil(response.errors)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
}

private struct Nested: Codable, Reflectable {
    var nestedVar: Int
    var nestedVarAnother: Date
}

private struct TestReflectableModel: Codable, Reflectable, Queryable {
    
    var testVar: String
    var nested: Nested
    
    static func buildQuery(with builder: QueryBuilder, context: QueryBuilderContext?) {
        let cont = builder.query()
        cont.addField(\TestReflectableModel.nested.nestedVar)
        cont.addField(\TestReflectableModel.testVar)
        cont.addField(\TestReflectableModel.nested.nestedVarAnother)
    }
    
}
