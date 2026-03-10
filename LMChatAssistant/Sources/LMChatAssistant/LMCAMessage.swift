//
//  LMCAMessage.swift
//  LMChatAssistant
//
//  Created by Dmytrii Golovanov on 07.03.2026.
//  Copyright © 2026 Dmytrii Golovanov. All rights reserved.
//

import Foundation

public struct LMCAMessage: Sendable {
    public let role: LMCARole
    public let content: String
    
    public init(role: LMCARole, content: String) {
        self.role = role
        self.content = content
    }
}
