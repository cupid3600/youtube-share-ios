//
//  Array+Slice.swift
//  VideoFace
//
//  Created by Marco Rossi on 16/10/2018.
//  Copyright © 2018 CYNNY. All rights reserved.
//

import Foundation

extension ArraySlice where Element: Equatable {
    /// Produces an array of slices representing the original
    /// slice split at each point where a user-supplied
    /// predicate evalutes to true.
    ///
    /// - Parameter predicate: a closure that tests whether a new element
    ///   should be added to the current partion
    /// - Parameter element: the element to be tested
    /// - Parameter nextElement: the successive element to be tested
    /// - Parameter maxPartitions: The maximum number of
    ///   subslices that can be produced
    ///
    /// - Returns: An array of array slices
    fileprivate func sliced(where predicate: (_ element: Element, _ nextElement: Element) -> Bool, maxPartitions: Int = .max ) -> [ArraySlice<Element>] {
        
        guard !isEmpty else { return [] }
        guard maxPartitions > 1, count > 1 else { return [self] }
        var (partitionIndex, nextPartitionIndex) = (startIndex, indices.index(after: startIndex))
        
        while nextPartitionIndex < endIndex, !predicate(self[partitionIndex], self[nextPartitionIndex]) {
            (partitionIndex, nextPartitionIndex) = (nextPartitionIndex, indices.index(after: nextPartitionIndex))
        }
        
        guard partitionIndex < endIndex else { return [self] }
        
        let (firstSlice, remainingSlice) = (self[startIndex ..<  nextPartitionIndex], self[nextPartitionIndex ..< endIndex])
        let rest = remainingSlice.sliced(where: predicate, maxPartitions: maxPartitions - 1)
        
        return [firstSlice] + rest
    }
}

extension Array where Element: Equatable {
    /// Produces an array of slices representing an
    /// array split at each point where a user-supplied
    /// predicate evalutes to true.
    ///
    /// ```
    /// [1, 2, 2, 3, 3, 3, 1]
    ///   .sliced(where: !=)
    /// // [ArraySlice([1]), ArraySlice([2, 2]), ArraySlice([3, 3, 3]), ArraySlice([1])]
    /// ```
    ///
    /// - Parameter predicate: a closure that tests whether a new element
    ///   should be added to the current partion
    /// - Parameter element: the element to be tested
    /// - Parameter nextElement: the successive element to be tested
    /// - Parameter maxPartitions: The maximum number of slices
    ///
    /// - Returns: An array of array slices
    public func sliced(where predicate: (_ element: Element, _ nextElement: Element) -> Bool, maxPartitions: Int = .max ) -> [ArraySlice<Element>] {
        return self[startIndex ..< endIndex].sliced(where: predicate, maxPartitions: maxPartitions)
    }
}
