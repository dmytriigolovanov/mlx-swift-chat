//
//  LMCAModel.swift
//  LMChatAssistant
//
//  Created by Dmytrii Golovanov on 07.03.2026.
//  Copyright © 2026 Dmytrii Golovanov. All rights reserved.
//

import Foundation

public enum LMCAModel: Sendable {
    case llama_v3_2_1B
    case llama_v3_2_3B
}

extension LMCAModel {
    var id: String {
        switch self {
        case .llama_v3_2_1B: 
            return "mlx-community/Llama-3.2-1B-Instruct-4bit"
        case .llama_v3_2_3B: 
            return "mlx-community/Llama-3.2-3B-Instruct-4bit"
        }
    }
    
    var promptFormat: LMCAPromptFormat {
        switch self {
        case .llama_v3_2_1B, .llama_v3_2_3B:
            return .llama3
        }
    }
}
