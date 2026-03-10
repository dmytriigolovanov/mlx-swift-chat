//
//  LMCAIntegrationTests.swift
//  LMChatAssistant
//
//  Created by Dmytrii Golovanov on 07.03.2026.
//  Copyright © 2026 Dmytrii Golovanov. All rights reserved.
//

import Testing
@testable import LMChatAssistant

struct LMCAIntegrationTests {
    private func makeAssistant(quality: LMCAConfiguration.Quality = .fast,
                               systemPrompt: String? = nil) -> LMChatAssistant {
        LMChatAssistant(configuration: LMCAConfiguration(
            model: .llama_v3_2_1B,
            quality: quality
        ))
    }

    // MARK: - Load

    @Test func testModelLoads() async throws {
        let chat = makeAssistant()
        try await chat.load()
    }

    @Test func testLoadWithProgressReports() async throws {
        let chat = makeAssistant()
        var progressValues: [Double] = []

        for try await progress in await chat.loadWithProgress() {
            progressValues.append(progress)
        }

        #expect(!progressValues.isEmpty)
        #expect(progressValues.last == 1.0)
    }

    // MARK: - Generate

    @Test func testGenerateReturnsNonEmptyResponse() async throws {
        let chat = makeAssistant()
        try await chat.load()

        let messages = [LMCAMessage(role: .user, content: "Say hello")]
        let response = try await chat.output(for: messages)

        #expect(!response.isEmpty)
    }

    @Test func testGenerateRespectsMaxTokens() async throws {
        let chat = makeAssistant(quality: .fast)
        try await chat.load()

        let messages = [LMCAMessage(role: .user, content: "Tell me a very long story")]
        let response = try await chat.output(for: messages)
        
        let wordCount = response.split(separator: " ").count
        #expect(wordCount < 300)
    }

    @Test func testGenerateWithSystemPrompt() async throws {
        let chat = makeAssistant(quality: .fast,
                                 systemPrompt: "Always respond with exactly one word.")
        try await chat.load()

        let messages = [LMCAMessage(role: .user, content: "How are you?")]
        let response = try await chat.output(for: messages)

        #expect(!response.isEmpty)
    }

    @Test func testGenerateWithHistory() async throws {
        let chat = makeAssistant()
        try await chat.load()
        
        let name = "Dmytrii"
        let messages = [
            LMCAMessage(role: .user, content: "My name is \(name)"),
            LMCAMessage(role: .assistant, content: "Nice to meet you, \(name)!"),
            LMCAMessage(role: .user, content: "What is my name?")
        ]
        let response = try await chat.output(for: messages)

        #expect(response.lowercased().contains(name.lowercased()))
    }

    // MARK: - Stream

    @Test func testStreamReturnsTokens() async throws {
        let chat = makeAssistant()
        try await chat.load()

        let messages = [LMCAMessage(role: .user, content: "Say hello")]
        var tokens: [String] = []

        for try await token in await chat.outputStream(for: messages) {
            tokens.append(token)
        }

        #expect(!tokens.isEmpty)
        #expect(!tokens.joined().isEmpty)
    }

    @Test func testStreamAndGenerateReturnSimilarContent() async throws {
        let chat = makeAssistant()
        try await chat.load()

        let messages = [LMCAMessage(role: .user, content: "What is 2 + 2?")]

        let fullResponse = try await chat.output(for: messages)

        var streamedTokens: [String] = []
        for try await token in await chat.outputStream(for: messages) {
            streamedTokens.append(token)
        }
        let streamedResponse = streamedTokens.joined()
        
        #expect(fullResponse.contains("4"))
        #expect(streamedResponse.contains("4"))
    }

    // MARK: - Errors

    @Test func testSendThrowsIfNotLoaded() async throws {
        let chat = makeAssistant()
        let messages = [LMCAMessage(role: .user, content: "Hello")]

        await #expect(throws: LMCAError.modelNotLoaded) {
            try await chat.output(for: messages)
        }
    }
}
