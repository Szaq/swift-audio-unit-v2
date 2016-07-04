//
//  HostIdentifier.swift
//  TestConvolution
//
//  Created by Łukasz Kwoska on 13/05/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import Foundation

struct HostIdentifier {
    let hostName: String
    let hostVersion: AUNumVersion
}


struct AUHostIdentifierConverter: PropertyValueConverter {
    func get(value: HostIdentifier) -> AUHostIdentifier {
        let hostNSString = value.hostName as NSString
        let hostCFString = hostNSString as CFString
        let unmanagedString = Unmanaged.passUnretained(hostCFString)

        return AUHostIdentifier(hostName: unmanagedString, hostVersion: value.hostVersion)
    }

    func set(value: AUHostIdentifier) -> HostIdentifier {
        let hostCFString = value.hostName.takeUnretainedValue()
        let hostNSString = hostCFString as NSString
        let host = hostNSString as String

        return HostIdentifier(hostName: host, hostVersion: value.hostVersion)
    }
}