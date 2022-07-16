import Foundation

struct KeychainWrapperError: Error {
    
    var message: String?
    var type: KeychainErrorType
    
    enum KeychainErrorType {
        case badData
        case servicesError
        case itemNotFound
        case unableToConvertToString
    }
    
    init(status: OSStatus, type: KeychainErrorType) {
        self.type = type
        
        if let errorMessage = SecCopyErrorMessageString(status, nil) {
            self.message = String(errorMessage)
        }
        else {
            self.message = "Status Code: \(status)"
        }
    }
    
    init(type: KeychainErrorType) {
        self.type = type
    }
    
    init(message: String, type: KeychainErrorType) {
        self.message = message
        self.type = type
    }
}

class KeychainWrapper {
    func storeDeviceIdFor(deviceId: String) throws {
        guard let passwordData = deviceId.data(using: .utf8) else {
            print("Error converting value to data.")
            throw KeychainWrapperError(type: .badData)
        }
        
        // 1
        let query: [String: Any] = [
            // 2
            kSecClass as String: kSecClassGenericPassword,
            // 3
            kSecAttrAccount as String: "WEBCARD",
            // 4
            kSecAttrService as String: "WEBCARDUSER",
            // 5
            kSecValueData as String: passwordData
        ]
        
        // 1
        let status = SecItemAdd(query as CFDictionary, nil)
        switch status {
        // 2
        case errSecSuccess:
            break
        case errSecDuplicateItem:
            break
        // 3
        default:
            throw KeychainWrapperError(status: status, type: .servicesError)
        }
    }
    
    func getDeviceId() throws -> String {
        let query: [String: Any] = [
            // 1
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "WEBCARD",
            kSecAttrService as String: "WEBCARDUSER",
            // 2
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            // 3
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status != errSecItemNotFound else {
            throw KeychainWrapperError(type: .itemNotFound)
        }
        
        guard status == errSecSuccess else {
            throw KeychainWrapperError(status: status, type: .servicesError)
        }
        
        guard let existingItem = item as? [String: Any],
              // 2
              let valueData = existingItem[kSecValueData as String] as? Data,
              // 3
              let value = String(data: valueData, encoding: .utf8)
        else {
            // 4
            throw KeychainWrapperError(type: .unableToConvertToString)
        }
        
        //5
        return value
    }
}

