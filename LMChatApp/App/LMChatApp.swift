//
//  LMChatApp.swift
//  LMChatApp
//
//  Created by Dmytrii Golovanov on 07.03.2026.
//  Copyright © 2026 Dmytrii Golovanov. All rights reserved.
//

import SwiftUI

@main
struct LMChatApp: App {
    @State private var chatManager = ChatManager()
    
    var body: some Scene {
        WindowGroup {
            
            ChatView(
                viewModel: ChatViewModel(
                    chat: chatManager.newChat(
                        withGreeting: true,
                        responseMode: .stream
                    )
                )
            )
            .environment(chatManager)
            .onAppear {
                // Disable tabs
                NSWindow.allowsAutomaticWindowTabbing = false
                
                // Moving window over the other apps
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}
