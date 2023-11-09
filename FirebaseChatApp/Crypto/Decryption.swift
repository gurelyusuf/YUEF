//
//  Decryption.swift
//  FirebaseChatApp
//
//  Created by GUREL on 8.11.2023.
//

import Foundation
import CryptoKit


class Decrpytion {
    
    static func decryptText(text: String, using symmetricKey: SymmetricKey) -> String {
        do {
            guard let data = Data(base64Encoded: text) else {
                return "Metnin kodu çözülemedi"
        
            }
            
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decyptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
            
            guard let text = String(data: decyptedData, encoding: .utf8) else{
                return "Veri kodu çözülemedi"
            }
            
            return text
        }catch let error {
            return "Şifrelenmiş mesaj hatası: \(error.localizedDescription)"
        }
    }
}
