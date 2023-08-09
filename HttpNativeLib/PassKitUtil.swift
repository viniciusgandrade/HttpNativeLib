//
//  PassKitUtil.swift
//  HttpNativeLib
//
//  Created by Vinícius Gonçalves de Andrade on 09/08/23.
//

import Foundation
import CoreGraphics
import PassKit

public class PassKitUtil {
    public func convertToPassCard(dataArray: [[String: Any]]) {
        // Filter the array based on your criteria
        let filteredArray = dataArray.compactMap { item -> [String: Any]? in
            var modifiedItem = item
            guard let tokens = item["tokens"] as? [[String: Any]], !tokens.isEmpty else {
                // Filter out if no tokens or empty tokens array
                return modifiedItem
            }
            
            let watchConnectivityManager = WatchConnectivityManager.shared
            let pairedDevicesInfo = watchConnectivityManager.checkPairedDevices()
            
            for token in tokens {
                if let tokenUniqueReference = token["tokenUniqueReference"] as? String,
                   let primaryAccountNumberSuffix = item["nrCartao"] as? String {
                    let passInfo = self.findPassInWallet(forSuffix: primaryAccountNumberSuffix)
                    if tokenUniqueReference == passInfo["walletDeviceId"] as! String && (pairedDevicesInfo["isWatchPaired"] == nil) || (pairedDevicesInfo["isWatchPaired"] != nil) && tokenUniqueReference == passInfo["walletWatchId"] as! String {
                        return nil
                    } else if tokenUniqueReference == passInfo["walletDeviceId"] as! String {
                        modifiedItem["walletDeviceId"] = passInfo["walletDeviceId"] as! String
                    }
                    return modifiedItem
                }
            }
            return nil
        }
        var passEntries: [PKIssuerProvisioningExtensionPaymentPassEntry] = []
        for filteredItem in filteredArray {
            if let imageURL = URL(string: filteredItem["produtoImagem"] as! String),
               let cgImage = self.convertImageURLToCGImage(url: imageURL) {
                let configuration = PKAddPaymentPassRequestConfiguration(encryptionScheme: PKEncryptionScheme.ECC_V2)
                configuration?.cardholderName = filteredItem["nomeEmbossado"] as? String
                configuration?.primaryAccountSuffix = filteredItem["nrCartao"] as? String
                configuration?.paymentNetwork = filteredItem["bandeira"] as? String == "visa" ? PKPaymentNetwork.visa : PKPaymentNetwork.masterCard
                configuration?.localizedDescription = filteredItem["produto"] as? String
                let id = String(filteredItem["idCartao"] as? Int64 ?? 0)
                let passEntry = PKIssuerProvisioningExtensionPaymentPassEntry(identifier: id, title: filteredItem["produto"] as! String, art: cgImage, addRequestConfiguration: configuration!)
                passEntries.append(passEntry!)
            }
        }
    }

    func convertImageURLToCGImage(url: URL) -> CGImage? {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
        else {
            return nil
        }
        return cgImage
    }

    func findPassInWallet(forSuffix suffix: String) -> [String: Any] {
        var resultDictionary: [String: Any] = [
            "isInWallet": "False",
            "isInWatch": "False",
            "FPANID": "",
            "walletDeviceId": "",
            "walletWatchId": ""
        ]
        
        let passLib = PKPassLibrary()
        
        if #available(iOS 13.4, *) {
            for pass in passLib.passes(of: .secureElement) as! [PKSecureElementPass] {
                if pass.primaryAccountNumberSuffix == suffix {
                    resultDictionary["isInWallet"] = "True"
                    resultDictionary["FPANID"] = pass.primaryAccountIdentifier
                    resultDictionary["walletDeviceId"] = pass.deviceAccountIdentifier
                    break
                }
            }
        } else {
            for pass in passLib.passes(of: .payment) as! [PKPaymentPass] {
                if pass.primaryAccountNumberSuffix == suffix {
                    resultDictionary["isInWallet"] = "True"
                    resultDictionary["FPANID"] = pass.primaryAccountIdentifier
                    resultDictionary["walletDeviceId"] = pass.deviceAccountIdentifier
                    break
                }
            }
        }
        
        return resultDictionary
    }
}
