//
//  ExtensionHelper.swift
//  TvFootball
//
//  Created by admin on 8/9/18.
//  Copyright © 2018 Le Tien An. All rights reserved.
//

import UIKit
import CryptoSwift

extension String {
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
    
    func aesAndBase64Encrypt(key: String) -> String? {
        do {
            let keyBytes: Array<UInt8> = key.bytes
            let inputBytes: Array<UInt8> = self.bytes
            let encryptedData = try AES(key: keyBytes, blockMode: ECB(), padding: .pkcs5).encrypt(inputBytes)
            return encryptedData.toBase64()
        } catch { }
        return nil
    }
    func aesAndBase64Decript(key: String) -> String? {
        do {
            guard let encodedBase64Data = Data(base64Encoded: self) else {
                return nil
            }
            let keyBytes: Array<UInt8> = key.bytes
            let inputBytes: Array<UInt8> = encodedBase64Data.bytes
            let decryptedData = try AES(key: keyBytes, blockMode: ECB(), padding: .pkcs5).decrypt(inputBytes)
            let decrypted = String(bytes: decryptedData, encoding: .utf8)
            return decrypted
        } catch { }
        return nil
    }
}

extension Int {
    func fromIntToDateStr() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm dd-MM-YYYY"
        
        return formatter.string(from: date)
    }
}
