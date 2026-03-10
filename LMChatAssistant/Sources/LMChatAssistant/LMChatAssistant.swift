//
//  LMChatAssistant.swift
//  LMChatAssistant
//
//  Created by Dmytrii Golovanov on 07.03.2026.
//  Copyright © 2026 Dmytrii Golovanov. All rights reserved.
//

import Foundation
import MLXLMCommon

public final class LMChatAssistant: Sendable {
    private let engine: LMCAEngine
    
    public var isLoaded: Bool {
        get async {
            return await engine.isLoaded
        }
    }

    public init(configuration: LMCAConfiguration) {
        self.engine = LMCAEngine(configuration: configuration)
    }
    
    // MARK: Model Loading
    
    public func loadWithProgress() async -> AsyncThrowingStream<Double, Error> {
        return await engine.loadWithProgress()
    }
    
    public func load() async throws {
        for try await _ in await loadWithProgress() { }
    }
    
    // MARK: Output Generation
    
    public func output(for messages: [LMCAMessage]) async throws -> String {
        return try await engine.generateOutput(for: messages)
    }
    
    public func outputStream(for messages: [LMCAMessage]) async -> AsyncThrowingStream<String, Error> {
        return await engine.generateOutputStream(for: messages)
    }
}
