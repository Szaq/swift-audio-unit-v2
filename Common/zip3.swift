//
//  zip3.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 08/06/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation

public func zip3<Sequence1 : SequenceType, Sequence2 : SequenceType, Sequence3 : SequenceType>(sequence1: Sequence1, _ sequence2: Sequence2, _ sequence3: Sequence3) -> Zip3Sequence<Sequence1, Sequence2, Sequence3> {
    return Zip3Sequence(sequence1, sequence2, sequence3)
}


/// A generator for `Zip3Sequence`.
public struct Zip3Generator<Generator1 : GeneratorType, Generator2 : GeneratorType, Generator3 : GeneratorType> : GeneratorType {
    public typealias Element = (Generator1.Element, Generator2.Element, Generator3.Element)

    private var generator1: Generator1
    private var generator2: Generator2
    private var generator3: Generator3

    /// Construct around a pair of underlying generators.
    public init(_ generator1: Generator1, _ generator2: Generator2, _ generator3: Generator3) {
        self.generator1 = generator1
        self.generator2 = generator2
        self.generator3 = generator3
    }

    /// Advance to the next element and return it, or `nil` if no next
    /// element exists.
    ///
    /// - Requires: `next()` has not been applied to a copy of `self`
    ///   since the copy was made, and no preceding call to `self.next()`
    ///   has returned `nil`.
    public mutating func next() -> (Generator1.Element, Generator2.Element, Generator3.Element)? {
        guard let element1 = generator1.next(), element2 = generator2.next(), element3 = generator3.next() else {
            return nil
        }

        return (element1, element2, element3)
    }
}

/// A sequence of triads built out of three underlying sequences, where
/// the elements of the `i`th triad are the `i`th elements of each
/// underlying sequence.
public struct Zip3Sequence<Sequence1 : SequenceType, Sequence2 : SequenceType, Sequence3 : SequenceType> : SequenceType {

    private let sequence1: Sequence1
    private let sequence2: Sequence2
    private let sequence3: Sequence3

    public typealias Generator = Zip3Generator<Sequence1.Generator, Sequence2.Generator, Sequence3.Generator>
    /// Construct an instance that makes triads of elements from `sequence1`, `sequence2`
    /// `sequence3`.
    public init(_ sequence1: Sequence1, _ sequence2: Sequence2, _ sequence3: Sequence3) {
        self.sequence1 = sequence1
        self.sequence2 = sequence2
        self.sequence3 = sequence3
    }

    /// Returns a generator over the elements of this sequence.
    ///
    /// - Complexity: O(1).
    public func generate() -> Zip3Generator<Sequence1.Generator, Sequence2.Generator, Sequence3.Generator> {
        return Zip3Generator(sequence1.generate(), sequence2.generate(), sequence3.generate())
    }
}