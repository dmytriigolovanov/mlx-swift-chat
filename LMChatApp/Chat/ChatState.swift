//
//  ChatState.swift
//  LMChatApp
//
//  Created by Dmytrii Golovanov on 08.03.2026.
//  Copyright © 2026 Dmytrii Golovanov. All rights reserved.
//

import Foundation

enum ChatState: Equatable {
    case notLoaded
    case loading(progress: Double)
    case idle
    case responding
}

extension ChatState {
    var isLoaded: Bool {
        switch self {
        case .notLoaded, .loading:
            return false
        case .idle, .responding:
            return true
        }
    }
}
