//
//  String+Extensions.swift
//  WeatherTracker
//
//  Created by Matvey Kostukovsky on 12/22/24.
//

import Foundation

extension StringProtocol where Self: RangeReplaceableCollection {
    mutating func removeNonLetters() {
        removeAll {
            guard let unicodeScalar = $0.unicodeScalars.first else { return false }
            return !CharacterSet.letters.contains(unicodeScalar)
        }
    }
    var alphaOnly: Self {
        var output = self
        output.removeNonLetters()
        return output
    }
}
