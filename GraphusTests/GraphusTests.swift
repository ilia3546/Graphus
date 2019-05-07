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

    var client: GraphusClient = {
        let url = URL(string: "http://localhost:8080/graphql")!
        return GraphusClient(url: url, configuration: .default)
    }()
    
    func testClient() {
        XCTAssertNotNil(self.client)
    }
    
    func testQuery() {
        let query = Query("authors", arguments: ["first":10], fields: ["firstName", "secondName"])
        XCTAssertEqual(query.fieldString, "authors(first: 10){firstName,secondName}")
    }
    
    func testSend() {
        let expectation = XCTestExpectation()
        let query = Query("authors", arguments: ["first":10], fields: ["firstName", "secondName"])
        self.client.query(query).send { result in
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
