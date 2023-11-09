//
//  ChatUser.swift
//  FirebaseChatApp
//
//  Created by GUREL on 1.11.2023.
//

import Foundation
import CryptoKit

struct ChatUser: Identifiable {
    
    var id: String{uid}
    let uid: String
    let imageProfile: String
    let email: String
    // Private ve public key fieldları:
    var privateKey: P256.KeyAgreement.PrivateKey?
    var publicKey: String? {
        Encryption.exportPublicKey(privateKey?.publicKey)
    }
}
