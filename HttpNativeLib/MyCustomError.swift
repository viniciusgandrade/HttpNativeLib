import Foundation

enum MyCustomError: Error {
    case networkError(message: String)
    case serverError(code: Int, message: String, details: [String: Any]?)
    case unknownError
}

extension MyCustomError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return NSLocalizedString(message, comment: "")
        case .serverError(_, let message, _):
            return NSLocalizedString(message, comment: "")
        case .unknownError:
            return NSLocalizedString("An unknown error occurred.", comment: "")
        }
    }
}
