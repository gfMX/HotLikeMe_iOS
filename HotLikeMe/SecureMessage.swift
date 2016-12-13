//
//  SecureMessage.swift
//  HotLikeMe
//
//  Created by developer on 12/12/16.
//  Copyright © 2016 MezcalDev. All rights reserved.
//

import Foundation

class SecureMessage {
 
    static func decrypt (str: String) -> String {
        
        let text = str.substring(to: str.index(str.startIndex, offsetBy: str.characters.count - 38))
        
        let SaltRange = str.index(str.startIndex, offsetBy: str.characters.count - 38) ..< str.index(str.startIndex, offsetBy: str.characters.count - 25)
        let RSalt = str.substring(with: SaltRange)
        
        let RIVRange = str.index(str.startIndex, offsetBy: str.characters.count - 25)
        let RIV = str.substring(from: RIVRange)
        
        print("Salt: \(RSalt) IV: \(RIV) Text: \(text)")
        
        //Testing zone

        
        
        //Testing Zone ended
        
        let Salt = base64ToByteArray(base64String: RSalt)
        let IVV = base64ToByteArray(base64String: RIV)
        
        print("Decoded \nSalt: \(Salt)\nIVV: \(IVV)\n")
        
        return ""
    }
    
    static func base64ToByteArray(base64String: String) -> [UInt8]? {
        if let nsdata = NSData(base64Encoded: base64String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) {
            var bytes = [UInt8](repeating: 0, count: nsdata.length)
            nsdata.getBytes(&bytes, length: bytes.count) //getBytes(&bytes)
            
            return bytes
        }
        return nil // Invalid input
    }
}

