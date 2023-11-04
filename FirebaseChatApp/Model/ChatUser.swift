//
//  ChatUser.swift
//  FirebaseChatApp
//
//  Created by GUREL on 1.11.2023.
//

import FirebaseFirestoreSwift

struct ChatUser: Codable, Identifiable {
    @DocumentID var id: String?
    let uid, email, profileImageUrl: String
}
