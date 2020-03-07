//
//  OSLog+PencilKit-Layers.swift
//  PencilKit-Layers
//
//  Created by Andrew Finke on 3/7/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import Foundation
import os.log

extension OSLog {
    
    // MARK: - Types -
    
    private enum CustomCategory: String {
        case model, controller
    }
    
    // MARK: - Properties -
    
    private static let subsystem: String = {
        guard let identifier = Bundle.main.bundleIdentifier else { fatalError() }
        return identifier
    }()
    
    static let model = OSLog(subsystem: subsystem, category: CustomCategory.model.rawValue)
    static let controller = OSLog(subsystem: subsystem, category: CustomCategory.controller.rawValue)
}
