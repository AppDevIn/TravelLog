//
//  Places.swift
//  TravelLog
//
//  Created by Jeya Vishnu on 30/1/21.
//

import Foundation


class Place: Codable {
    let title, highlightedTitle: String
    let vicinity, highlightedVicinity: String?
    let position: [Double]?
    let category, categoryTitle: String?
    let href: String
    let type, resultType: String
    let id: String?
    let distance: Int?
    let chainIDS: [String]?

    enum CodingKeys: String, CodingKey {
        case title, highlightedTitle, vicinity, highlightedVicinity, position, category, categoryTitle, href, type, resultType, id, distance
        case chainIDS = "chainIds"
    }

    init(title: String, highlightedTitle: String, vicinity: String?, highlightedVicinity: String?, position: [Double]?, category: String?, categoryTitle: String?, href: String, type: String, resultType: String, id: String?, distance: Int?, chainIDS: [String]?) {
        self.title = title
        self.highlightedTitle = highlightedTitle
        self.vicinity = vicinity
        self.highlightedVicinity = highlightedVicinity
        self.position = position
        self.category = category
        self.categoryTitle = categoryTitle
        self.href = href
        self.type = type
        self.resultType = resultType
        self.id = id
        self.distance = distance
        self.chainIDS = chainIDS
    }
}
