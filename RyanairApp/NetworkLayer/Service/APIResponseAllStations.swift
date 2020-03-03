//
//  APIResponseAllStations.swift
//  RyanairApp
//
//  Created by Cathal Farrell on 28/02/2020.
//  Copyright © 2020 Cathal Productions. All rights reserved.
//

import Foundation

struct Station: Decodable {
    var code: String!
    var name: String!
    var markets: [Market]!

    enum CodingKeys: String, CodingKey {
        case code, name, markets
    }
}

struct Market: Decodable {
    var code: String!

    enum CodingKeys: String, CodingKey {
        case code
    }
}

struct APIResponseAllStations: Decodable {

    var stations: [Station]!

    enum CodingKeys: String, CodingKey {
        case stations
    }
}
