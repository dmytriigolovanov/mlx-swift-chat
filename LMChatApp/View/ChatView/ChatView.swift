//
//  ChatView.swift
//  LMChatApp
//
//  Created by Dmytrii Golovanov on 08.03.2026.
//  Copyright © 2026 Dmytrii Golovanov. All rights reserved.
//

import SwiftUI

struct ChatView: View {
    @State var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack {
            messagesView
            Divider()
            inputBar
        }
        .onAppear {
            viewModel.viewDidAppear()
        }
        .onChange(of: viewModel.isInputAvailable) { _, isAvailable in
            if isAvailable {
                isInputFocused = true
            }
        }
        .overlay {
            if !viewModel.isLoaded {
                let progress = viewModel.loadingProgress ?? 0.0
                loadingProgressOverlay(progress: progress)
            }
        }
    }
    
    @ViewBuilder
    private func loadingProgressOverlay(progress: Double) -> some View {
        ZStack {
            Color(.windowBackgroundColor).opacity(0.85)
            VStack(spacing: 12) {
                Text("Loading...")
                    .font(.headline)
                ProgressView(value: progress)
                    .frame(width: 200)
                Text("\(Int(progress * 100))%")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
    
    @ViewBuilder
    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        ChatMessageContainerView(
                            message: message,
                            isResponding: viewModel.shouldShowResponding(for: message)
                        )
                    }
                    Color.clear
                        .frame(height: 1)
                        .id("bottom")
                }
                .padding()
            }
            .onChange(of: viewModel.messages) {
                proxy.scrollTo("bottom", anchor: .bottom)
            }
        }
    }
    
    @ViewBuilder
    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField("Message...", text: $viewModel.inputText, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...5)
                .padding(8)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .focused($isInputFocused)
                .onSubmit {
                    viewModel.sendMessage()
                }
            
            Button(action: viewModel.sendMessage, label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title)
            })
            .disabled(!viewModel.isSendAvailable)
            .buttonStyle(.plain)
        }
        .disabled(!viewModel.isInputAvailable)
        .padding(12)
    }
}

private struct ChatMessageContainerView: View {
    let message: ChatMessage
    let isResponding: Bool

    @State private var typingIndicatorDotCount = 0

    private var isUser: Bool {
        return message.role == .user
    }
    private var content: String {
        var content = message.content
        if isResponding {
            content += String(repeating: ".", count: typingIndicatorDotCount + 1)
        }
        return content
    }
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }
            
            contentView
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .textSelection(.enabled)
            
            if message.role != .user {
                Spacer()
            }
        }
        .padding(8)
    }
    
    @ViewBuilder
    private var contentView: some View {
        Text(content)
            .foregroundStyle(foregroundColor)
            .task(id: isResponding) {
                guard isResponding else {
                    return
                }
                while !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(300))
                    typingIndicatorDotCount = (typingIndicatorDotCount + 1) % 3
                }
            }
    }
    
    private var backgroundColor: Color {
        switch message.role {
        case .user:
            return .accentColor
        case .assistant:
            return Color(.underPageBackgroundColor)
        }
    }
    
    private var foregroundColor: Color {
        switch message.role {
        case .user:
            return .white
        case .assistant:
            return .primary
        }
    }
}

#Preview {
    ChatView(
        viewModel: ChatViewModel(
            chat: ChatManager().newChat(
                withGreeting: true,
                responseMode: .stream
            )
        )
    )
}

#Preview {
    ChatMessageContainerView(
        message: ChatMessage(
            role: .user,
            content: "Hello!"
        ),
        isResponding: true
    )
    ChatMessageContainerView(
        message: ChatMessage(
            role: .assistant,
            content: "Wake up, Neo..."
        ),
        isResponding: true
    )
}
