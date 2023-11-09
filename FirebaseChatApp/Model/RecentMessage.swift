//
//  RecentMessage.swift
//  FirebaseChatApp
//
//  Created by GUREL on 1.11.2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct RecentMessage: Identifiable {
    var id: String {documentId}
    let documentId: String
    let text, toId, fromId : String
    let timestamp: Timestamp
    let email: String
    let profileImageUrl: String
    
    init(documentId: String, data:[String: Any]) {
        self.documentId = documentId
        self.text = data["Text"] as? String ?? ""
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date: Date())
    }
   
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp.dateValue(), relativeTo: Date())
    }
    
    var username: String {
        return email.components(separatedBy: "@").first ?? email
    }
}

