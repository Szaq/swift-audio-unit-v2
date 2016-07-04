//
//  ListensForPropertyChanges.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 13/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation

protocol ObservesPropertyChanges : AnyObject, HasProperties {

    func registerPropertyObservers()

    func notifyPropertyChanged(id: AudioUnitPropertyID)
}

extension ObservesPropertyChanges {

    func registerPropertyObservers() {
        for (id, property) in properties() {
            property.onChange {[weak self] _ in
                self?.notifyPropertyChanged(id)
            }
        }
    }

}