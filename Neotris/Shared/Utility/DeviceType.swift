//
//  DeviceType.swift
//  Neotris
//
//  Created by Rishi Singh on 30/03/25.
//

enum DeviceType {
    case iPhone, iPad, mac, unknown
    
    static var current: DeviceType {
#if os(iOS)
        return UIService.screenWidth < 450 ? .iPhone : .iPad
#elseif os(macOS)
        return .mac
#else
        return .unknown
#endif
    }
}
