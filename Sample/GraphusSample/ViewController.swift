//
//  ViewController.swift
//  GraphusSample
//
//  Created by Ilya Kharlamov on 23.11.2020.
//

import UIKit
import Graphus

class ViewController: UIViewController {

    var client: GraphusClient = {
        let url = URL(string: "http://localhost:8080/graphql")!
        return GraphusClient(url: url, configuration: .default)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let query = Query("authors", arguments: ["first":10], fields: ["firstName", "secondName"])
        self.client.request(.query, query: query).send { result in
            switch result{
            case .failure(let error):
                print("Error:", error)
            case .success(let response):
                print("Success:", response)
            }
        }
    }

}

