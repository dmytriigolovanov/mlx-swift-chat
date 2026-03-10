//
//  ChatMessage.swift
//  LMChatApp
//
//  Created by Dmytrii Golovanov on 08.03.2026.
//  Copyright © 2026 Dmytrii Golovanov. All rights reserved.
//

import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let role: ChatRole
    var content: String
    
    init(id: UUID = UUID(),
         role: ChatRole,
         content: String) {
        self.id = id
        self.role = role
        self.content = content
    }
}

extension ChatMessage {
    static func assistantGreeting() -> ChatMessage {
        return ChatMessage(role: .assistant, content: "Hello! How can I help you?")
    }
}
