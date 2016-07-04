//
//  QualifiedElementID.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 13/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation


struct QualifiedElementID {
    let id: AudioUnitElement
    let scopeID: AudioUnitScope
    let audioUnit: AudioUnit
}

extension QualifiedElementID {
    func propertyID(id: AudioUnitPropertyID) -> QualifiedPropertyID {
        return QualifiedPropertyID(propertyID: id, scopeID: scopeID, elementID: self.id, audioUnit: audioUnit)
    }
}