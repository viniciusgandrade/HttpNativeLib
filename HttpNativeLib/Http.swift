//
//  Http.swift
//  HttpNativeLib
//
//  Created by Vinícius Gonçalves de Andrade on 07/08/23.
//

import Foundation
import Alamofire

public class Http {
    var session: Session?
    var timeoutInterval = 30
    @objc func initialize(_ timeoutInterval: Int = 30, certPath: String) {
        self.timeoutInterval = timeoutInterval
        let host = "*.brbcard.com.br"
        guard let certificateURL = Bundle.main.url(forResource: certPath, withExtension: nil),
              let certificateData = try? Data(contentsOf: certificateURL)
        else {
            print("Falha SSL Pinning")
            return
        }
        
        let pinnedCertificates: [SecCertificate] = [SecCertificateCreateWithData(nil, certificateData as CFData)!]
        let serverTrustEvaluator = PinnedCertificatesTrustEvaluator(
            certificates: pinnedCertificates,
            acceptSelfSignedCertificates: true,
            performDefaultValidation: true,
            validateHost: true
        )
        
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(self.timeoutInterval)
        
        let evaluators: [String: ServerTrustEvaluating] = [
            host: serverTrustEvaluator,
            "": DefaultTrustEvaluator()
        ]
        
        let manager = WildcardServerTrustPolicyManager(evaluators: evaluators)
        self.session = Session(configuration: configuration, serverTrustManager: manager)
    }
    
    func request(url: String, method: String = "POST", _headers: [String: Any], data: [String:Any], completion: @escaping (Result<Data, Error>) -> Void) {
        
        let contentType = _headers["Content-Type"] as? String ?? "application/json"
        
        var encoder: ParameterEncoder = JSONParameterEncoder.default
        if (contentType == "application/x-www-form-urlencoded" || method == "GET") {
            encoder = URLEncodedFormParameterEncoder.default
        }
        
        var headers: HTTPHeaders = [];
        
        for (_, option) in _headers.enumerated() {
            headers.add(name: option.key, value: option.value as! String)
        }
        headers.add(name: "User-Agent", value: "App/\(getAppVersion()) (\(deviceName()); \(deviceVersion()); Scale/\(getScreenScale()))")
        
        var request: DataRequest?;
        let url1 = URL(string: url)!
        if (method == "GET") {
            var parameters: [String: String] = [:];
            
            for (_, option) in data.enumerated() {
                if let value = option.value as? String {
                    parameters[option.key] = value
                } else {
                    parameters[option.key] = (option.value as? NSNumber)?.stringValue
                }
            }
            request = self.session?.request(url, method: HTTPMethod(rawValue: method), parameters: parameters, encoder: encoder, headers: headers);
        } else {
            guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []) else {
                print("JSON inválido")
                return;
            }
            var urlRequest = URLRequest(url: url1)
            urlRequest.httpMethod = method
            urlRequest.headers = headers
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonData
            
            request = self.session?.request(urlRequest)
        }
        
        request?
            .validate(statusCode: 200..<300)
            .response { response in
                print ("response: \(response.debugDescription)")
                if let curlRequest = response.request?.debugDescription {
                    print("cURL command: \(curlRequest)")
                }
                switch response.result {
                case .success(let data):
                    completion(.success(data!))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    //eg. Darwin/16.3.0
    func DarwinVersion() -> String {
        var sysinfo = utsname()
        uname(&sysinfo)
        let dv = String(bytes: Data(bytes: &sysinfo.release, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
        return "Darwin/\(dv)"
    }
    //eg. CFNetwork/808.3
    func CFNetworkVersion() -> String {
        let dictionary = Bundle(identifier: "com.apple.CFNetwork")?.infoDictionary!
        let version = dictionary?["CFBundleShortVersionString"] as! String
        return "CFNetwork/\(version)"
    }
    
    //eg. iOS/10_1
    func deviceVersion() -> String {
        let currentDevice = UIDevice.current
        return "\(currentDevice.systemName) \(currentDevice.systemVersion)"
    }
    //eg. iPhone5,2
    func deviceName() -> String {
        //        var sysinfo = utsname()
        //        uname(&sysinfo)
        //        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
        return UIDevice.current.model
    }
    
    func getScreenScale() -> String {
        return String(format: "%.2f", UIScreen.main.scale)
    }
    
    func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
}

class WildcardServerTrustPolicyManager: ServerTrustManager {
    override func serverTrustEvaluator(forHost host: String) throws -> ServerTrustEvaluating? {
        if let policy = evaluators[host] {
            return policy
        }
        var domainComponents = host.split(separator: ".")
        if domainComponents.count > 2 {
            domainComponents[0] = "*"
            let wildcardHost = domainComponents.joined(separator: ".")
            return evaluators[wildcardHost]
        }
        return nil
    }
}
