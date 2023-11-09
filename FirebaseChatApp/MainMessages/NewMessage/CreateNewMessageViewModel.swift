//
//  CreateNewMessageViewModel.swift
//  FirebaseChatApp
//
//  Created by GUREL on 9.11.2023.
//

import Foundation
import SwiftUI


class CreateNewMessageViewModel: ObservableObject {
    
    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    
    init() {
        fetchAllUsers()
    }
    
    private func fetchAllUsers() {
        FirebaseManager.shared.firestore.collection("users").getDocuments { documentSnapshot, error in
            
            if let error = error {
                self.errorMessage = "Firebase'den tüm kullanıcılar çekilirken hata: \(error.localizedDescription)"
                print("Firebase'den tüm kullanıcılar çekilirken hata: \(error.localizedDescription)")
                return
            }
            
            //we have good data
            
            documentSnapshot?.documents.forEach({ snapshot in
                let data = snapshot.data()
                let uid = data["uid"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let profileImageUrl = data["profileImageUrl"]  as? String ?? ""
                
                let user = ChatUser(uid: uid, imageProfile: profileImageUrl, email: email)
                if user.uid != FirebaseManager.shared.auth.currentUser?.uid { //do not allow to send message to self user
                    self.users.append(user)
                }
                
            })
            
            self.errorMessage = "Tüm kullanıcılar başarıyla çekildi"
            
        }
    }
}
