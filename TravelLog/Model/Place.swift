// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let place = try? newJSONDecoder().decode(Place.self, from: jsonData)

import Foundation

// MARK: - Place
class Place {
    let results: Results
    let search: Search
    
    init(results: Results, search: Search) {
        self.results = results
        self.search = search
    }
}

// MARK: - Results
class Results {
    let next: String
    let items: [Item]
    
    init(next: String, items: [NSDictionary]) {
        self.next = next
        self.items = items.map({ (NsDictionary) -> Item in
            return Item(item: NsDictionary)
        })
    }
}

// MARK: - Item
class Item {
    let position: [Double]
    let distance: Int
    let title: String
    let averageRating: Int
    let category: Category
    let icon: String
    let vicinity: String
    let type: String
    let href: String
    var tags: [Tag] = []
    let id: String
    let openingHours: OpeningHours?
    let alternativeNames: [AlternativeName]?
    let chainIDS: [String]?
    
    init(item value: NSDictionary) {
        self.position = value["position"] as! [Double]
        self.distance = value["distance"] as! Int
        self.title = value["title"] as! String
        self.averageRating = value["averageRating"] as! Int
        self.category = Category(from: value["category"] as! NSDictionary)
        self.icon = value["icon"] as! String
        self.vicinity = value["vicinity"] as! String
        self.type = value["type"] as! String
        self.href = value["href"] as! String
        if let tags = value["tags"] as! [NSDictionary]? {
            self.tags = tags.map({ (NsDictionary) -> Tag in
                return Tag(from: NsDictionary)
            })
        }
        self.id = value["id"] as! String
        
        if let openingHours = value["openingHours"] as! NSDictionary? {
            self.openingHours = OpeningHours(from: openingHours)
        } else {self.openingHours = nil}
        
        if let alternativeName = value["alternativeName"] as! [NSDictionary]? {
            self.alternativeNames = alternativeName.map({ (alternative) -> AlternativeName in
                return AlternativeName(from: alternative)
            })
        } else {self.alternativeNames = nil}
        
        if let chainIDS = value["chainIDS"] as! [String]? {
            self.chainIDS = chainIDS
        } else {self.chainIDS = nil}
        
    }
}

// MARK: - AlternativeName
class AlternativeName: Codable {
    let name: String
    let language: String
    
    init(from data:NSDictionary) {
        self.name = data["name"] as! String
        self.language = data["language"] as! String
    }
}


// MARK: - Category
class Category {
    let id, title: String
    let href: String
    let type: String
    let system: String
    
    init(from data:NSDictionary) {
        self.id = data["id"] as! String
        self.title = data["title"] as! String
        self.href = data["href"] as! String
        self.type = data["type"] as! String
        self.system = data["system"] as! String
    }
}

// MARK: - OpeningHours
class OpeningHours: Codable {
    let text: String
    let label: String
    let isOpen: Bool
    let structured: [Structured]
    
    init(from data: NSDictionary) {
        self.text = data["text"] as! String
        self.label = data["label"] as! String
        self.isOpen = data["isOpen"] as! Bool
        self.structured = (data["structured"] as! [NSDictionary]).map({ (NsDictionary) -> Structured in
            return Structured(from: NsDictionary)
        })
    }
}



// MARK: - Structured
class Structured: Codable {
    let start, duration, recurrence: String
    
    init(from data:NSDictionary) {
        self.start = data["start"] as! String
        self.duration = data["duration"] as! String
        self.recurrence = data["recurrence"] as! String
    }
}

// MARK: - Tag
class Tag {
    let id, title: String
    let group: String
    
    init(from data:NSDictionary) {
        self.id = data["id"] as! String
        self.title = data["title"] as! String
        self.group = data["group"] as! String
    }
}

enum Group: String, Codable {
    case cuisine = "cuisine"
}

enum ItemType: String, Codable {
    case urnNLPTypesPlace = "urn:nlp-types:place"
}

// MARK: - Search
class Search: Codable {
    let context: Context
    
    init(context: Context) {
        self.context = context
    }
}

// MARK: - Context
class Context: Codable {
    let location: Location
    let type: ItemType
    let href: String
    
    init(location: Location, type: ItemType, href: String) {
        self.location = location
        self.type = type
        self.href = href
    }
}

// MARK: - Location
class Location: Codable {
    let position: [Double]
    let address: Address
    
    init(position: [Double], address: Address) {
        self.position = position
        self.address = address
    }
}

// MARK: - Address
class Address: Codable {
    let text, street, district, city: String
    let county, country, countryCode: String
    
    init(text: String, street: String, district: String, city: String, county: String, country: String, countryCode: String) {
        self.text = text
        self.street = street
        self.district = district
        self.city = city
        self.county = county
        self.country = country
        self.countryCode = countryCode
    }
}
