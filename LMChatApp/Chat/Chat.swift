//
//  Chat.swift
//  LMChatApp
//
//  Created by Dmytrii Golovanov on 07.03.2026.
//  Copyright © 2026 Dmytrii Golovanov. All rights reserved.
//

import Foundation

enum ChatError: Error {
    case chatIsBusy
    case updatedMessageNotFound
}

enum ChatResponseMode {
    case stream
    case complete
}

@Observable
final class Chat: Identifiable {
    let id: UUID = UUID()
    let assistant: ChatAssistant
    let responseMode: ChatResponseMode
    
    private(set) var messages: [ChatMessage]
    private(set) var state: ChatState = .notLoaded
    
    init(assistant: ChatAssistant,
         messages: [ChatMessage] = [],
         responseMode: ChatResponseMode = .complete) {
        self.assistant = assistant
        self.messages = messages
        self.responseMode = responseMode
    }
    
    // MARK: Loading
    
    func load() async {
        guard await !assistant.isLoaded else {
            state = .idle
            return
        }
        do {
            for try await progress in await assistant.loadWithProgress() {
                state = .loading(progress: progress)
            }
            state = .idle
        } catch {
            state = .notLoaded
        }
    }
    
    // MARK: Messages
    
    private func addMessage(_ message: ChatMessage) {
        messages.append(message)
    }
    
    private func updateContentInMessage(withId id: UUID, block: (String) -> String) throws {
        guard let index = messages.firstIndex(where: { $0.id == id }) else {
            throw ChatError.updatedMessageNotFound
        }
        messages[index].content = block(messages[index].content)
    }
    
    func sendMessage(_ content: String) async {
        do {
            guard state == .idle else {
                throw ChatError.chatIsBusy
            }
            state = .responding
            
            let sentMessage = ChatMessage(role: .user, content: content)
            messages.append(sentMessage)
            
            let outputMessage = ChatMessage(role: .assistant, content: "")
            messages.append(outputMessage)
            
            switch responseMode {
            case .stream:
                for try await token in await assistant.outputStream(for: messages) {
                    try updateContentInMessage(withId: outputMessage.id) { content in
                        return content + token
                    }
                }
                
            case .complete:
                let outputContent = try await assistant.output(for: messages)
                try updateContentInMessage(withId: outputMessage.id) { content in
                    return outputContent
                }
            }
        }
        catch {
            handle(error: error)
        }
        
        state = .idle
    }
    
    // MARK: Error Handling
    
    private func handle(error: Error) {
        // handle error
    }
}

extension Chat {
    static func withAssistantGreeting(assistant: ChatAssistant,
                                      responseMode: ChatResponseMode) -> Chat {
        Chat(assistant: assistant,
             messages: [.assistantGreeting()],
             responseMode: responseMode)
    }
}
