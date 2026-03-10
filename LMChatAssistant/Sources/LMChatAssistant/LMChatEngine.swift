//
//  LMCAEngine.swift
//  LMChatAssistant
//
//  Created by Dmytrii Golovanov on 07.03.2026.
//  Copyright © 2026 Dmytrii Golovanov. All rights reserved.
//

import Foundation
import MLXLMCommon
import MLXLLM

actor LMCAEngine {
    private let configuration: LMCAConfiguration
    private let promptBuilder: LMCAPromptBuilder
    private var modelContainer: MLXLMCommon.ModelContainer?
    
    var isLoaded: Bool {
        return modelContainer != nil
    }
    
    init(configuration: LMCAConfiguration) {
        self.configuration = configuration
        self.promptBuilder = LMCAPromptBuilder(format: configuration.model.promptFormat,
                                               systemPrompt: configuration.systemPrompt)
    }
    
    // MARK: Model Loading
    
    func loadWithProgress() -> AsyncThrowingStream<Double, Error> {
        AsyncThrowingStream { continuation in
            guard !isLoaded else {
                continuation.finish()
                return
            }
            
            Task {
                do {
                    let modelConfig = MLXLMCommon.ModelConfiguration(id: self.configuration.model.id)
                    self.modelContainer = try await MLXLLM.LLMModelFactory.shared.loadContainer(configuration: modelConfig) { progress in
                        continuation.yield(progress.fractionCompleted)
                    }
                    continuation.finish()
                }
                catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    private func getContainer() throws -> ModelContainer {
        guard let modelContainer else {
            throw LMCAError.modelNotLoaded
        }
        return modelContainer
    }
    
    // MARK: Output Generation
    
    func generateOutput(for messages: [LMCAMessage]) async throws -> String {
        let container = try getContainer()
        let prompt = promptBuilder.build(from: messages)
        let params = GenerateParameters(maxTokens: configuration.quality.maxTokens,
                                        temperature: configuration.quality.temperature)

        return try await container.perform { context in
            let input = try await context.processor.prepare(input: UserInput(prompt: prompt))
            var result = ""
            for await item in try MLXLMCommon.generate(input: input, parameters: params, context: context) {
                switch item {
                case .chunk(let text):
                    result += text
                case .info:
                    break
                case .toolCall:
                    break
                }
            }
            return result
        }
    }
    
    func generateOutputStream(for messages: [LMCAMessage]) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let container = try self.getContainer()
                    let prompt = self.promptBuilder.build(from: messages)
                    let params = GenerateParameters(maxTokens: self.configuration.quality.maxTokens,
                                                    temperature: self.configuration.quality.temperature)

                    try await container.perform { context in
                        let input = try await context.processor.prepare(input: UserInput(prompt: prompt))
                        for await item in try MLXLMCommon.generate(input: input, parameters: params, context: context) {
                            switch item {
                            case .chunk(let text):
                                continuation.yield(text)
                            case .info:
                                break
                            case .toolCall:
                                break
                            }
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
