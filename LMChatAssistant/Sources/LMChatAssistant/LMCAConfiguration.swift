//
//  LMCAConfiguration.swift
//  LMChatAssistant
//
//  Created by Dmytrii Golovanov on 07.03.2026.
//  Copyright © 2026 Dmytrii Golovanov. All rights reserved.
//

import Foundation

public struct LMCAConfiguration: Sendable {
    public enum Quality: Sendable {
        case fast
        case balanced
        case best
    }
    
    public let model: LMCAModel
    public let quality: Quality
    public let systemPrompt: String?
    
    public init(model: LMCAModel,
                quality: Quality = .balanced,
                systemPrompt: String? = nil) {
        self.model = model
        self.quality = quality
        self.systemPrompt = systemPrompt
    }
}

extension LMCAConfiguration.Quality {
    var maxTokens: Int {
        switch self {
        case .fast:     return 256
        case .balanced: return 512
        case .best:     return 1024
        }
    }

    var temperature: Float {
        switch self {
        case .fast:     return 0.3
        case .balanced: return 0.7
        case .best:     return 1.0
        }
    }
}
