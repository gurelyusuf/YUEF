//
//  Encryption.swift
//  FirebaseChatApp
//
//  Created by GUREL on 8.11.2023.
//

import Foundation
import CryptoKit

class Encryption {
    
    //MARK: Generate private key
    static func generatePrivateKey() -> P256.KeyAgreement.PrivateKey {
        let privateKey = P256.KeyAgreement.PrivateKey()
        return privateKey
    }
    
    //MARK: Extract private key
    
    static func extractPublicKeyFromPrivate(privateKey: P256.KeyAgreement.PrivateKey) -> P256.KeyAgreement.PublicKey {
        
        return  privateKey.publicKey
    }
    
    //MARK: public key to string
    static func exportPublicKey(_ publicKey: P256.KeyAgreement.PublicKey?) -> String? {
        
        if let publicKey = publicKey {
            let rawPublicKey = publicKey.rawRepresentation
            let base64PublicKey = rawPublicKey.base64EncodedString()
            let encodedPublicKey = base64PublicKey.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
            return encodedPublicKey
        }
        
        return nil
    }
    
    //MARK: string to public key
    
    static func convertStringToPublicKey(_ publicKey: String?) throws ->  P256.KeyAgreement.PublicKey? {
        if let publicKeyString = publicKey {
            let publicKeyBase64 = publicKeyString.removingPercentEncoding!
            let rawPublicKey = Data(base64Encoded: publicKeyBase64)!
            
            return try P256.KeyAgreement.PublicKey(rawRepresentation: rawPublicKey)
        }
        
        return nil
    }
    
    
    //MARK: Private Key to String
    static func convertPrivateKeyToString(_ privateKey: P256.KeyAgreement.PrivateKey) -> String {
        let rawKey = privateKey.rawRepresentation
        let privateKeyBase64 = rawKey.base64EncodedString()
        let percentEncodedPrivateKey = privateKeyBase64.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        return percentEncodedPrivateKey
    }
    
    
    //MARK: String to Private Key
    static func convertStringToPrivateKey(_ privateKeyString: String) throws -> P256.KeyAgreement.PrivateKey {
        let privateKeyBase64 = privateKeyString.removingPercentEncoding!
        let rawPrivateKey = Data(base64Encoded: privateKeyBase64)!
        
        return try P256.KeyAgreement.PrivateKey(rawRepresentation: rawPrivateKey)
    }
    
    //MARK: Creating symmetric key
    
    //Diffie-Hellman Key Exchange
    
    static func deriveSymmtericKey(privateKey: P256.KeyAgreement.PrivateKey, publicKey: P256.KeyAgreement.PublicKey) throws -> SymmetricKey {
        
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)
        
        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(using: SHA256.self, salt: "Special Salt".data(using: .utf8)!, sharedInfo: Data(), outputByteCount: 32)
        
        return symmetricKey
    }
    
    
    //MARK: Encrypt Text
    
    static func encryptText(text: String, using symmetricKey: SymmetricKey) throws -> String {
        
        let textData = text.data(using: .utf8)!
        let encrpyted = try AES.GCM.seal(textData, using: symmetricKey)
        
        return encrpyted.combined!.base64EncodedString()
        
    }
    
}
