//
//  ChatManager.swift
//  LMChatApp
//
//  Created by Dmytrii Golovanov on 07.03.2026.
//  Copyright © 2026 Dmytrii Golovanov. All rights reserved.
//

import Foundation
import LMChatAssistant

@Observable
final class ChatManager {
    private let assistant: ChatAssistant
    // For future multi-chat mode
    private var chats: [Chat] = []
    
    init() {
        let configuration = LMCAConfiguration(model: .llama_v3_2_1B,
                                              quality: .balanced)
        let lmChatAssistant = LMChatAssistant(configuration: configuration)
        self.assistant = DefaultChatAssistant(assistant: lmChatAssistant)
    }
    
    // MARK: Prepare
    
    func prepare() async throws {
        try await assistant.load()
    }
    
    // MARK: Chat
    
    func newChat(withGreeting: Bool, responseMode: ChatResponseMode) -> Chat {
        let chat: Chat = {
            if withGreeting {
                return Chat.withAssistantGreeting(assistant: assistant, responseMode: responseMode)
            }
            else {
                return Chat(assistant: assistant, responseMode: responseMode)
            }
        }()
        chats.append(chat)
        return chat
    }
}
