//
//  SHA256.swift
//  HttpNativeLib
//
//  Created by Vinícius Gonçalves de Andrade on 09/08/23.
//

import Foundation
import CommonCrypto

public func sha256(_ input: String) -> String {
    if let data = input.data(using: .utf8) {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = data.withUnsafeBytes {
            CC_SHA256($0.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
    return ""
}
