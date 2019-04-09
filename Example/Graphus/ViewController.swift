//
//  ViewController.swift
//  Graphus
//
//  Created by ilia3546 on 04/05/2019.
//  Copyright (c) 2019 ilia3546. All rights reserved.
//

import UIKit
import Graphus

class ViewController: UIViewController {

    lazy var client: GraphusClient = {
        
        let configuration = URLSessionConfiguration.default
        // Add additional headers as needed
        configuration.httpAdditionalHeaders = ["Authorization": "Bearer <token>"] // Replace `<token>`
        
        let serverUrl = URL(string: "https://example-server.graphql.com")!
        let client = GraphusClient(url: serverUrl, configuration: configuration)
        client.debugParams = [.logRequests, .printQueries]
        return client
        
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.fetchBooks()
        self.createBook()
    }
    
    func fetchBooks(){
        
        let query = Query("allBooks", model: Book.self)
        client.query(query).onResponse(mapToObject: [Book].self) { result in
            do{
                let response = try result.get()
                print("Books list", response.data)
                print("GraphQL errors", response.errors)
            }catch{
                print("Error", error.localizedDescription)
            }
        }
      
    }

    func createBook(){
        
        var query = Query("createBook", model: Book.self)
        query.appendArguments(["title": "Francis Scott Key Fitzgerald", "author": "The Great Gatsby"])
        
        client.mutation(query).onResponse(mapToObject: Book.self) { result in
            do{
                let response = try result.get()
                print("New book", response.data)
                print("GraphQL errors", response.errors)
            }catch{
                print("Error", error.localizedDescription)
            }
        }

    }

}

