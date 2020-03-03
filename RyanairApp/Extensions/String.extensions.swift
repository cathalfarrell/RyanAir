//
//  String.extensions.swift
//  RyanairApp
//
//  Created by Cathal Farrell on 01/03/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Foundation

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(upTo: Int) -> String {
        let toIndex = index(from: upTo)
        return String(self[..<toIndex])
    }

    func substring(with range: Range<Int>) -> String {
        let startIndex = index(from: range.lowerBound)
        let endIndex = index(from: range.upperBound)
        return String(self[startIndex..<endIndex])
    }

    func startsWith(string: String) -> Bool {
        //Used in the station filter to retrieve results like Münster etc
        guard let range = range(of: string, options: [.caseInsensitive, .diacriticInsensitive]) else {
            return false
        }
        return range.lowerBound == startIndex
    }
}
