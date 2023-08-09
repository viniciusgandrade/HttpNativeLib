//
//  Http.swift
//  HttpNativeLib
//
//  Created by Vinícius Gonçalves de Andrade on 07/08/23.
//

import Foundation
import Alamofire

public class HttpRequest {
    var session: Session?
    var timeoutInterval = 30
    public init() {}
    public func initialize(timeoutInterval: Int = 30) {
        self.timeoutInterval = timeoutInterval
        let host = "*.brbcard.com.br"
        guard let certificateURL = Bundle(url: Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent())?.url(forResource: "public/certificates/brbcard_22.cer", withExtension: nil),
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
    
    public func request(url: String, method: String = "POST", _headers: [String: Any], data: inout[String:Any], completion: @escaping (Result<[String : Any], Error>) -> Void) {
        
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
            let newJSON: [String: Any] = [
                "versao": self.getAppVersion(),
                "build": self.getBuildVersion(),
                "plataforma": "ios",
                "appId": self.getBundleId()
            ]
            data.merge(newJSON) { (_, new) in new }

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
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            completion(.success(json))
                        } else {
                            // JSON format is incorrect or not a dictionary
                            let parsingError = NSError(domain: "JSONParsingError", code: 0, userInfo: nil)
                            completion(.failure(parsingError))
                        }
                    } catch {
                        // JSON parsing error
                        completion(.failure(error))
                    }
                case .failure(_):
                    if let responseData = response.data,
                       let errorJSON = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                        // Extract error information from the JSON and create MyCustomError.serverError
                        let statusCode = response.response?.statusCode ?? 0
                        let message = errorJSON["msg"] as? String ?? "Unknown error"
                        let details = errorJSON["erroCode"] as? [String: Any]
                        
                        let customError = MyCustomError.serverError(code: statusCode, message: message, details: details)
                        completion(.failure(customError))
                    } else {
                        // Fallback to MyCustomError.networkError
                        completion(.failure(MyCustomError.networkError(message: "Network request failed")))
                    }
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
    
    public func getBuildVersion() -> String {
        let mainAppBundleURL = Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent()
        if let mainAppBundle = Bundle(url: mainAppBundleURL),
           let appVersion = mainAppBundle.infoDictionary?["CFBundleVersion"] as? String {
            return appVersion
        }
        return ""
    }
    
    //eg. iOS/10_1
    func deviceVersion() -> String {
        let currentDevice = UIDevice.current
        return "\(currentDevice.systemName) \(currentDevice.systemVersion)"
    }
    //eg. iPhone5,2
    func deviceName() -> String {
        return UIDevice.current.model
    }
    
    func getScreenScale() -> String {
        return String(format: "%.2f", UIScreen.main.scale)
    }
    
    public func getAppVersion() -> String {
        let mainAppBundleURL = Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent()
        if let mainAppBundle = Bundle(url: mainAppBundleURL),
           let appVersion = mainAppBundle.infoDictionary?["CFBundleShortVersionString"] as? String {
            return appVersion
        }
        return ""
    }
    
    public func getBundleId() -> String {
        let mainAppBundleURL = Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent()
        if let mainAppBundle = Bundle(url: mainAppBundleURL) {
           return mainAppBundle.bundleIdentifier!
        }
        return ""
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
