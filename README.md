<p align="center">
<img src="https://raw.githubusercontent.com/ilia3546/Graphus/master/Images/logo.png" alt="Graphus" title="Graphus" width="305"/>
</p>

<p align="center">
<a href="https://travis-ci.org/ilia3546/Graphus"><img src="https://travis-ci.com/ilia3546/Graphus.svg?branch=0.1.6"></a>
<a href="https://github.com/Carthage/Carthage/"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
<a href="http://onevcat.github.io/Graphus/"><img src="https://img.shields.io/cocoapods/v/Graphus.svg?style=flat"></a>
<a href="https://raw.githubusercontent.com/ilia3546/Graphus/master/LICENSE"><img src="https://img.shields.io/cocoapods/l/Graphus.svg?style=flat"></a>
<a href="http://onevcat.github.io/Graphus/"><img src="https://img.shields.io/cocoapods/p/Graphus.svg?style=flat"></a>
</p>

Graphus is a powerful and strongly-typed, pure-Swift GraphQL client for iOS. It allows you to build GraphQL requests based on your models. If you like the project, do not forget to put **star ★**

# `Documentation in a writing process`

If you have a question you can message me at ilia3546@me.com or via telegram.

## Navigate

- [Quick example](#quick-example)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
	- [The Basics](#the-basics)
	- [Adding child models](#adding-child-models)
	- [Creating Query object](#creating-query-object)
	- [Creating a client](#creating-a-client)
	- [Sending requests to a server](#sending-requests-to-a-server)
	- [Arguments](#arguments)
- [License](#license)
- [Contact](#contact)

## Quick example

```swift

// Make simple model
struct Author: Decodable, Queryable {

    var firstName: String
    var secondName: String
    
    static func buildQuery(with builder: QueryBuilder) {
        let query = builder.query(keyedBy: CodingKeys.self)
        query.addField(.firstName)
        query.addField(.secondName)
    }
    
}

// Create query for retriving authors list
let authorsQuery = Query("authors", model: Author.self)

// Send request to the server & map response
self.client.request(authorsQuery).send(mapToDecodable: [Author].self) { (result) in
	switch result {
	case .success(let response):
		print("Authors", response.data)
		print("GraphQL errors", response.errors)
	case .failure(let error):
		print("Job failed: \(error.localizedDescription)")
	}
}

```


## Features
- [x] Building GraphQL requests based on your models.
- [x] Add any arguments to each field.
- [x] Mutation requests
- [x] GraphQL pagination support
- [x] Response mapping using **Codable** protocol
- [ ] [TODO] [ObjectMapper](https://github.com/tristanhimmelman/ObjectMapper) support


## Requirements

Swift 4.2 or **5.0**. Ready for use on iOS 10+


## Installation

### CocoaPods:

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate `Graphus` into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'Graphus' # Without mapping
pod 'Graphus/Codable' # Codable mapping support (recommended)
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate `Graphus` into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "ilia3546/Graphus"
```

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate `Graphus` into your project manually. Put `Source` folder in your Xcode project. Make sure to enable `Copy items if needed` and `Create groups`.

## Usage

### The Basics

To build requests which are based on your class or struct just needs to implement the **Queryable** protocol which includes the following static function:

```swift
static func buildQuery(with builder: QueryBuilder)
```

Graphus use `QueryBuilder` object to add fields and child models:

```swift
struct Book: Queryable {
    
    var title: String
    var isbn: String
    
    static func buildQuery(with builder: QueryBuilder) {
        let query = builder.query()
        query.addField("title")
        query.addField("isbn")
    }
    
}
```

Also you can create query keyed by CodingKeys if your model is implemented **Decodable** protocol and you use Codable intergration:

```swift
static func buildQuery(with builder: QueryBuilder) {
	let query = builder.query(keyedBy: CodingKeys.self)
	query.addField(.title)
	query.addField(.isbn)
}
```

The above example will generate following GraphQL request model:

```
{
	title, 
	isbn
}
```

### Adding child models

You can add child models to the GraqhQL request:

```swift
struct Author: Decodable, Queryable {
    
    var firstName: String
    var secondName: String
    var books: [Book]
    
    static func buildQuery(with builder: QueryBuilder) {
        let query = builder.query(keyedBy: CodingKeys.self)
        query.addField(.firstName)
        query.addField(.secondName)
        query.addChild(Book.self, forKey: .books)
    }
    
}

```

The above example will generate following GraphQL request model:

```
{
	firstName,
	secondName,
	books {
		title,
		isbn
	}
}
```


### Creating `Query` object

After you've created `GraphusClient` and models you could make your first `Query` object:

```swift
let authorsQuery = Query("authors", model: Author.self)
```

Also you can add some arguments (see [arguments](#arguments) section):

```swift
let authorArguments: Arguments = [
		"filter": [
			"age": 24
		]
	]
	
let authorsQuery = Query("authors", arguments: authorArguments, model: Author.self)
```

Also if you do not want you can use `[Field]` array:

```
let fields: [Field] = ["firstName", "secondName"]
let authorsQuery = Query("authors", fields: fields)
```

### Creating a client

In most cases, you'll want to create a single shared instance of `GraphusClient` and point it at your GraphQL server. The easiest way to do this is to define a global variable:

```swift
var client: GraphusClient = {
	let configuration = URLSessionConfiguration.default
	// Add additional headers as needed
	configuration.httpAdditionalHeaders = ["Authorization": "Bearer <token>"] // Replace `<token>`
	let url = URL(string: "http://localhost:8080/graphql")!
	return GraphusClient(url: url, configuration: configuration)
}()

```


### Sending requests to a server
*TODO*


### Arguments
*TODO*

## License
`Graphus` is released under the MIT license. Check `LICENSE.md` for details.

## Contact
If you need any application or UI to be developed, message me at ilia3546@me.com or via [telegram](https://t.me/bluetech_team). I develop iOS apps and designs. I use `swift` for development. To request more functionality, you should create a new issue.
