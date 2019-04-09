//
//  Book.swift
//  Graphus_Example
//
//  Created by Ilya Kharlamov on 05/04/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Graphus

/// Library model
struct Library: Decodable, Queryable, Mutable {
    
    /// Library address
    var address: Address
    
    /// Array of books in this library
    var books: [Book] = []
    
    static func buildQuery(with builder: QueryBuilder) {
        let query = builder.query(keyedBy: CodingKeys.self)
        query.addChild(Address.self, forKey: .address)
        query.addChild(Book.self, forKey: .books)
    }
    
    func mutationEncode(to encoder: MutationEncoder) {
        let container = encoder.container(keyedBy: CodingKeys.self)
        container.encode(address, forKey: .address)
        container.encode(books.compactMap({ $0.id }), forKey: .address)
    }
    
}

/// Book model
struct Book: Decodable, Queryable, Mutable {
    
    /// ID of the book
    var id: String?
    /// Title of the book
    var title: String
    /// Book's author
    var author: String
    /// ISBN number
    var isbn: String?
    /// URL link
    var url: String?
    
    init(title: String, author: String){
        self.title = title
        self.author = author
    }
    
    static func buildQuery(with builder: QueryBuilder) {
        let query = builder.query(keyedBy: CodingKeys.self)
        query.addField(.id)
        query.addField(.title)
        query.addField(.author)
        query.addField(.isbn)
        query.addField(.url)
    }
    
    func mutationEncode(to encoder: MutationEncoder) {
        let container = encoder.container(keyedBy: CodingKeys.self)
        container.encode(id, forKey: .id)
        container.encode(title, forKey: .title)
        container.encode(author, forKey: .author)
        container.encode(isbn, forKey: .isbn)
        container.encode(url, forKey: .url)
    }

}

/// Address model
struct Address: Decodable, Queryable, Mutable {
    
    var city: String
    var street: String
    var home: String
    
    static func buildQuery(with builder: QueryBuilder) {
        let query = builder.query(keyedBy: CodingKeys.self)
        query.addField(.city)
        query.addField(.street)
        query.addField(.home)
    }
    
    func mutationEncode(to encoder: MutationEncoder) {
        let container = encoder.container(keyedBy: CodingKeys.self)
        container.encode(city, forKey: .city)
        container.encode(street, forKey: .street)
        container.encode(home, forKey: .home)
    }
    
}
