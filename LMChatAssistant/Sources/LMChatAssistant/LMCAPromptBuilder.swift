//
//  LMCAPromptBuilder.swift
//  LMChatAssistant
//
//  Created by Dmytrii Golovanov on 07.03.2026.
//  Copyright © 2026 Dmytrii Golovanov. All rights reserved.
//

import Foundation
import MLXLMCommon

enum LMCAPromptFormat {
    case llama3
}

struct LMCAPromptBuilder {
    let format: LMCAPromptFormat
    let systemPrompt: String?
    
    init(format: LMCAPromptFormat, systemPrompt: String? = nil) {
        self.format = format
        self.systemPrompt = systemPrompt
    }
    
    func build(from messages: [LMCAMessage]) -> String {
        switch format {
        case .llama3:
            return buildLlama3(from: messages)
        }
    }
    
    private func buildLlama3(from messages: [LMCAMessage]) -> String {
        var prompt = "<|begin_of_text|>"
        
        if let systemPrompt {
            prompt += "<|start_header_id|>system<|end_header_id|>\n\n"
            prompt += "\(systemPrompt)<|eot_id|>"
        }
        
        for message in messages {
            let roleString = roleString(for: message.role)
            prompt += "<|start_header_id|>\(roleString)<|end_header_id|>\n\n"
            prompt += "\(message.content)<|eot_id|>"
        }
        
        prompt += "<|start_header_id|>assistant<|end_header_id|>\n\n"
        
        return prompt
    }
    
    private func roleString(for role: LMCARole) -> String {
        switch role {
        case .user:
            return MLXLMCommon.Chat.Message.Role.user.rawValue
        case .assistant:
            return MLXLMCommon.Chat.Message.Role.assistant.rawValue
        }
    }
}
