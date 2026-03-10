//
//  ChatAssistant.swift
//  LMChatApp
//
//  Created by Dmytrii Golovanov on 08.03.2026.
//  Copyright © 2026 Dmytrii Golovanov. All rights reserved.
//

import Foundation
import LMChatAssistant

protocol ChatAssistant {
    var isLoaded: Bool { get async }
    func load() async throws
    func loadWithProgress() async -> AsyncThrowingStream<Double, Error>
    func output(for messages: [ChatMessage]) async throws -> String
    func outputStream(for messages: [ChatMessage]) async -> AsyncThrowingStream<String, Error>
}

final class DefaultChatAssistant: ChatAssistant {
    private let assistant: LMChatAssistant
    
    var isLoaded: Bool {
        get async {
            return await assistant.isLoaded
        }
    }
    
    init(assistant: LMChatAssistant) {
        self.assistant = assistant
    }
    
    // MARK: Loading
    
    func load() async throws {
        guard await !isLoaded else {
            return
        }
        return try await assistant.load()
    }
    
    func loadWithProgress() async -> AsyncThrowingStream<Double, any Error> {
        return await assistant.loadWithProgress()
    }
    
    // MARK: Output
    
    func output(for messages: [ChatMessage]) async throws -> String {
        if await !isLoaded {
            try await load()
        }
        return try await assistant.output(for: messages.map(\.lmcaMessage))
    }
    
    func outputStream(for messages: [ChatMessage]) async -> AsyncThrowingStream<String, any Error> {
        if await !isLoaded {
            return AsyncThrowingStream { continuation in
                Task {
                    do {
                        try await load()
                        let stream = await assistant.outputStream(for: messages.map(\.lmcaMessage))
                        for try await token in stream {
                            continuation.yield(token)
                        }
                        continuation.finish()
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
            }
        }
        else {
            return await assistant.outputStream(for: messages.map(\.lmcaMessage))
        }
    }
}

// MARK: - Mapping

private extension ChatRole {
    var lmcaRole: LMCARole {
        switch self {
        case .user: return .user
        case .assistant: return .assistant
        }
    }
}

private extension ChatMessage {
    var lmcaMessage: LMCAMessage {
        LMCAMessage(role: role.lmcaRole, content: content)
    }
}
