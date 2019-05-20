//
//  ViewController.swift
//  Graphus-Demo
//
//  Created by Ilya Kharlamov on 07/05/2019.
//  Copyright © 2019 Ilya Kharlamov. All rights reserved.
//

import UIKit
import Graphus

class ViewController: UIViewController {

    var client: GraphusClient = {
        let configuration = URLSessionConfiguration.default
        // Add additional headers as needed
        configuration.httpAdditionalHeaders = ["Authorization": "Bearer <token>"] // Replace `<token>`
        let url = URL(string: "http://localhost:8080/graphql")!
        let client = GraphusClient(url: url, configuration: configuration)
        client.debugParams = [.printSendableQueries]
        return client
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authorsQuery = Query("authors", model: Author.self, context: Author.Context(incudeBooks: false))

        self.client.query(authorsQuery).send(mapToDecodable: [Author].self) { (result) in
            switch result{
            case .success(let response):
                print("Authors", response.data)
                print("GraphQL errors", response.errors)
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
    }

}

