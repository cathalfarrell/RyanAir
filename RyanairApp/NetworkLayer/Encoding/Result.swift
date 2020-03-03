//
//  Result.swift
//  RyanairApp
//
//  Created by Cathal Farrell on 18/07/2019.
//  Copyright © 2019 Cathal Farrell. All rights reserved.
//

import Foundation

enum Result<T> {

    case success(T)
    case failure(Error)
}
