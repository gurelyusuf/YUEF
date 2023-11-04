//
//  ChatMessage.swift
//  FirebaseChatApp
//
//  Created by GUREL on 1.11.2023.
//

import Foundation
import FirebaseFirestoreSwift

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let fromId, toId, text: String
    let timestamp: Date
}
