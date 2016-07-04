//
//  Dictionary.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 12/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation

func +<KEY, VALUE>(lhs:[KEY: VALUE], rhs:[KEY: VALUE]) -> [KEY: VALUE] {
    guard rhs.count > 0 else { return lhs}
    guard lhs.count > 0 else { return rhs}

    var mutable = lhs

    for (key, value) in rhs {
        mutable[key] = value
    }

    return mutable
}