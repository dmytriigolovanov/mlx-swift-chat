//
//  ChatViewModel.swift
//  LMChatApp
//
//  Created by Dmytrii Golovanov on 08.03.2026.
//  Copyright © 2026 Dmytrii Golovanov. All rights reserved.
//

import Foundation

@Observable
final class ChatViewModel {
    private let chat: Chat
    var inputText: String = ""
    
    var messages: [ChatMessage] {
        guard isLoaded else {
            return []
        }
        return chat.messages
    }
    var isLoaded: Bool {
        return chat.state.isLoaded
    }
    var loadingProgress: Double? {
        guard case .loading(let progress) = chat.state else {
            return nil
        }
        return progress
    }
    var isResponding: Bool {
        return chat.state == .responding
    }
    var isInputAvailable: Bool {
        return chat.state == .idle
    }
    var isSendAvailable: Bool {
        return chat.state == .idle && !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(chat: Chat) {
        self.chat = chat
    }
    
    func shouldShowResponding(for message: ChatMessage) -> Bool {
        return isResponding
        && message.role == .assistant
        && messages.contains(where: { $0.id == message.id })
    }
    
    func viewDidAppear() {
        Task {
            await chat.load()
        }
    }
    
    func sendMessage() {
        guard isSendAvailable else {
            return
        }
        
        Task {
            let content = inputText
            inputText = ""
            await chat.sendMessage(content)
        }
    }
}
