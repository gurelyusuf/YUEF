//
//  ChatLogViewModel.swift
//  FirebaseChatApp
//
//  Created by GUREL on 8.11.2023.
//

import Foundation
import Firebase
import CryptoKit

struct FirebaseConstants {
    
    static let fromId = "fromId"
    static let toId = "toId"
    static let text = "Text"
}

struct ChatMessage: Identifiable {
    
    var id: String { documentId }
    
    let documentId: String
    let fromId, toId, text: String
    var encryptedText: String?
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
    }
    
}
class ChatLogViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    @Published var chatMessages = [ChatMessage]()
    
    @Published var count = 0
    
    var chatUser: ChatUser?
    var encryptedText = ""
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        getMessages()
        
    }
    
    var firestoreListener: ListenerRegistration?
    
    func getMessages() {
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else{return}
        guard let toId = chatUser?.uid else {return}
        
        //we always want use our own private key and public key of the reciever
        
        guard let privateKey = FirebaseManager.shared.currentUser?.privateKey else{return}
        var symmetricKey: SymmetricKey?
        
        FirebaseManager.shared.firestore.collection("users").document(toId).getDocument{ [self] snapshot, error in
            
            if let error = error{
                print("alıcı olan kullanıcıdan veri çekerken hata: ")
                print(error.localizedDescription)
                return
            }
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "Veri bulunamadı"
                return
            }
            
            if let recieverPublicKey = data["publicKey"] as? String {
                do{
                    if let publicKey = try Encryption.convertStringToPublicKey(recieverPublicKey) {
                        symmetricKey = try Encryption.deriveSymmtericKey(privateKey: privateKey, publicKey: publicKey)
                        
                        chatMessages.removeAll()
                        
                        firestoreListener = FirebaseManager.shared.firestore.collection("messages")
                            .document(fromId)
                            .collection(toId)
                            .order(by: "timestamp")
                            .addSnapshotListener { querySnapshot, error in
                                
                                if let error = error {
                                    print("Firestore'dan veri çekerken hata: \(error.localizedDescription)")
                                    return
                                }
                                
                                querySnapshot?.documentChanges.forEach({ change in
                                    
                                    var messageData = change.document.data()
                                    if let symmetricKey = symmetricKey {
                                        messageData["Text"] = Decrpytion.decryptText(text:messageData["Text"] as? String ?? "", using:symmetricKey)
                                    }
                                    else{
                                        print("mesajları al -> symmetric key in null")
                                    }
                                    
                                    
                                    self.chatMessages.append(ChatMessage(documentId: change.document.documentID, data: messageData))
                                })
                                
                            }
                        
                        DispatchQueue.main.async {
                            self.count += 1
                        }
                    }
                    else{
                        print("public key getirilemedi -> mesajları al")
                    }
                    
                }
                catch{
                    print("şifreli mesaj hatası")
                    return
                }
            }
            else{
                print("could not read public key from user data")
            }
            
        }
        
    }
    
    func handleSend() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else{return}
        guard let toId = chatUser?.uid else {return}
        
        guard let senderPrivatekey = FirebaseManager.shared.currentUser?.privateKey else{
            print("handle send -> couldnt get private key from current user")
            return
            
        }
        
        
        FirebaseManager.shared.firestore.collection("users").document(toId).getDocument{ [self] snapshot, error in
            
            if let error = error{
                print("alıcı olan kullanıcıdan veri çekerken hata")
                print(error.localizedDescription)
                return
            }
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "Veri bulunamadı"
                return
            }
            
            if let recieverPublicKey = data["publicKey"] as? String {
                do{
                    if let publicKey = try Encryption.convertStringToPublicKey(recieverPublicKey){
                        let symmetricKey = try Encryption.deriveSymmtericKey(privateKey: senderPrivatekey, publicKey: publicKey)
                        self.encryptedText = try Encryption.encryptText(text: self.chatText, using: symmetricKey)
                        
                        let document = FirebaseManager.shared.firestore.collection("messages")
                            .document(fromId)
                            .collection(toId)
                            .document()
                        
                        let messageData = ["fromId": fromId, "toId": toId, "Text": self.encryptedText, "timestamp": Timestamp()] as [String: Any]
                        
                        document.setData(messageData) { error in
                            
                            if let err = error {
                                print(err.localizedDescription)
                                self.errorMessage = "mesajları firestore'a kaydederken hata \(err.localizedDescription)"
                                return
                            }
                            
                            self.persistRecentMessage()
                            
                            //hata yok
                            print("Mesajlar firestore'a kaydedildi")
                            self.chatText = ""
                        }
                        
                        let messageReceiverDocument = FirebaseManager.shared.firestore.collection("messages")
                            .document(toId)
                            .collection(fromId)
                            .document()
                        
                        messageReceiverDocument.setData(messageData) { error in
                            
                            if let error = error {
                                print(error)
                                self.errorMessage = "mesajları firestore'a kaydederken hata \(error)"
                                return
                            }
                            
                            //mesaj başarıyla kaydedildi
                            
                            print("alıcı mesajı başarıyla saklandı")
                            
                        }
                    }
                    else{
                        print("Public key hatası")
                    }
                    
                }
                catch{
                    print("şifreli mesaj hatası")
                    return
                }
                
            }
            
            else{
                print("public key alıcıdan alınamadı")
            }
            
        }
        
    }
    
    private func persistRecentMessage() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        
        guard let toId = self.chatUser?.uid else{return}
        
        var doc = FirebaseManager.shared.firestore.collection("recent_messages").document(uid).collection("messages").document(toId)
        
        let data = [
            "timestamp" : Timestamp(),
            "Text": self.encryptedText,
            "fromId": uid,
            "toId" : toId,
            "profileImageUrl": self.chatUser?.imageProfile as Any,
            "email": self.chatUser?.email as Any
            
        ] as [String : Any]
        
        doc.setData(data) { error in
            if let error  = error {
                print("son mesajları çekerken hata" + error.localizedDescription)
                return
            }
        }
        
        print("son mesajlar başarıyla kaydedildi")
        
        
        doc = FirebaseManager.shared.firestore.collection("recent_messages").document(toId).collection("messages").document(uid)
        
        guard let currentUser = FirebaseManager.shared.currentUser else { return }
        
        let recipientData =  [
            "timestamp" : Timestamp(),
            "Text": self.encryptedText,
            "fromId": uid,
            "toId" : toId,
            "profileImageUrl": currentUser.imageProfile as Any,
            "email": currentUser.email as Any
            
        ] as [String : Any]
        
        doc.setData(recipientData) { error in
            if let error  = error {
                print("son mesajları kaydederken hata" + error.localizedDescription)
                return
            }
        }
        
        print("son mesajlar başarıyla kaydedildi")
    }
    
}
