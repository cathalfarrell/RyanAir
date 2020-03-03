//
//  APIResponseSearchFlights.swift
//  RyanairApp
//
//  Created by Cathal Farrell on 01/03/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Foundation

struct Fare: Decodable {
    var amount: Double!
    var count: Int!
    var type: String!
    var hasDiscount: Bool!
    var publishedFare: Double!

    enum CodingKeys: String, CodingKey {
        case amount, count, type, hasDiscount, publishedFare
    }
}

struct RegularFare: Decodable {
    var fares: [Fare]!

    enum CodingKeys: String, CodingKey {
        case fares
    }
}

struct Flight: Decodable {
    var time: [String]!
    var flightNumber: String!
    var regularFare: RegularFare!

    enum CodingKeys: String, CodingKey {
        case time, flightNumber, regularFare
    }
}

struct FlightDates: Decodable {
    var dateOut: String!
    var flights: [Flight]!

    enum CodingKeys: String, CodingKey {
        case dateOut, flights
    }
}

struct Trip: Decodable {
    var origin: String!
    var destination: String!
    var dates: [FlightDates]!

    enum CodingKeys: String, CodingKey {
        case origin, destination, dates
    }
}

struct APIResponseSearchFlights: Decodable {

    var currency: String!
    var trips: [Trip]!

    enum CodingKeys: String, CodingKey {
        case currency, trips
    }
}
