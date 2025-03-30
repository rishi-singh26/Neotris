//
//  DeviceType.swift
//  Neotris
//
//  Created by Rishi Singh on 30/03/25.
//

#if os(iOS)
import UIKit
#endif

enum DeviceType {
    case iPhone, iPad, mac, unknown
    
    static var current: DeviceType {
#if os(iOS)
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return .iPhone
        case .pad:
            return .iPad
        default:
            return .unknown
        }
#elseif os(macOS)
        return .mac
#else
        return .unknown
#endif
    }
}
