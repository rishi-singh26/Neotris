//
//  UIService.swift
//  Neotris
//
//  Created by Rishi Singh on 11/03/25.
//

import SwiftUI

class UIService {
    static var screenWidth: CGFloat {
#if os(iOS) || os(visionOS)
        return UIScreen.main.bounds.width
#elseif os(macOS)
        return NSScreen.main?.frame.width ?? 0
#else
        return 0
#endif
    }
    
    static var screenHeight: CGFloat {
#if os(iOS) || os(visionOS)
        return UIScreen.main.bounds.height
#elseif os(macOS)
        return NSScreen.main?.frame.height ?? 0
#else
        return 0
#endif
    }
}
