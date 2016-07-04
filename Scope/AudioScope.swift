//
//  Scope.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 09/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation

typealias AudioElementGenerator = () throws -> AudioElement

class AudioScope: ObservesPropertyChanges {
    let parent: AudioUnitBase
    let id: AudioUnitScope

    var elements = [AudioElement]()
    let numberOfElements: Property<UInt32>

    let elementType: AudioElement.Type

    init<ElementType: AudioElement>(id: AudioUnitScope, parent: AudioUnitBase, elementType:ElementType.Type,numElements: UInt32) throws {
        numberOfElements = Property(0, writable: true)
        self.id = id
        self.parent = parent
        self.elementType = elementType
        
        numberOfElements.onChange { [weak self] _ in
            do {
                try self?.createElements()
            } catch let error {
                Log.error("Failed to create elements due to numberOfElements change: \(error)")
            }
        }
        numberOfElements.value = numElements

        registerPropertyObservers()
    }

    func createElements() throws {
        switch Int(numberOfElements.value) - elements.count {
        case let numberOfElementsToAdd where numberOfElementsToAdd > 0:
            let elementsToAdd = try (AudioUnitElement(elements.count) ..< AudioUnitElement(numberOfElements.value)).map {
                return try elementType.init($0, parent: self)
            }
            elements.appendContentsOf(elementsToAdd)

        case let numberOfElementsToRemove where numberOfElementsToRemove < 0:
            elements.removeLast(numberOfElementsToRemove)

        default:
            break
        }
    }

    func getElement(id: Int) -> AudioElement? {
        guard id < elements.count else {return nil}
        return elements[id]
    }

    func allocateBuffers() {
        for element in elements {
            element.allocateBuffer()
        }
    }

    func properties() -> [AudioUnitPropertyID: PropertyType] {
        return [kAudioUnitProperty_ElementCount: numberOfElements]
    }

    func getExtraPropertyInfo(id: QualifiedPropertyID) throws -> OutputDataDescription {
        guard let element = getElement(Int(id.elementID)) else {
            throw AudioUnitError.InvalidProperty}

        return try element.getPropertyInfo(id)
    }

    func getExtraProperty(id: QualifiedPropertyID) throws -> OutputData {
        guard let element = getElement(Int(id.elementID)) else {
            throw AudioUnitError.InvalidProperty}

        return try element.getProperty(id)
    }

    func setExtraProperty(id: QualifiedPropertyID, data: InputData) throws {

        guard let element = getElement(Int(id.elementID)) else {
            throw AudioUnitError.InvalidProperty}

        try element.setProperty(id, data: data)
    }

    func notifyPropertyChanged(id: AudioUnitPropertyID) {
        parent.notifyPropertyChanged(
            QualifiedPropertyID(
                propertyID: id,
                scopeID: self.id,
                elementID: 0,
                audioUnit: parent.instance))
    }
}