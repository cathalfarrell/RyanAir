//
//  HTTPNetworkError.swift
//  RyanairApp
//
//  Created by Cathal Farrell on 02/07/2019.
//  Copyright © 2019 Cathal Farrell. All rights reserved.
//

import Foundation

// The enumeration defines possible errors to encounter during Network Request
public enum HTTPNetworkError: String, Error {

    case parametersNil = "Error Found : Parameters are nil."
    case headersNil = "Error Found : Headers are Nil"
    case encodingFailed = "Error Found : Parameter Encoding failed."
    case decodingFailed = "Error Found : Unable to Decode the data."
    case missingURL = "Error Found : The URL is nil."
    case couldNotParse = "Error Found : Unable to parse the JSON response."
    case noData = "Error Found : The data from API is Nil."
    case fragmentResponse = "Error Found : The API's response's body has fragments."
    case unwrappingError = "Error Found : Unable to unwrap the data."
    case dataTaskFailed = "Error Found : The Data Task object failed."
    case success = "Successful Network Request"
    case authenticationError = "Error Found : You must be Authenticated"
    case badRequest = "Error Found : Bad Request"
    case resourceNotFound = "Error Found : Resource requested not found."
    case failed = "Error Found : Network Request failed"
    case serverSideError = "Error Found : Server error"
    case forbiddenError = "Error Found : You don't have permission to access this server."
}
