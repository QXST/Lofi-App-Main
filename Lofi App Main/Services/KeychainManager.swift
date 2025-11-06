//
//  KeychainManager.swift
//  Lofi App Main
//
//  Created by Quest on 11/5/25.
//

import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()

    private init() {}

    // MARK: - Keys
    private enum Keys {
        static let authToken = "com.lofiapp.authToken"
        static let refreshToken = "com.lofiapp.refreshToken"
        static let userID = "com.lofiapp.userID"
    }

    // MARK: - Save
    func save(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        // Delete any existing item
        delete(forKey: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    // MARK: - Retrieve
    func retrieve(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    // MARK: - Delete
    func delete(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    // MARK: - Clear All
    func clearAll() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    // MARK: - Convenience Methods
    func saveAuthToken(_ token: String) -> Bool {
        save(token, forKey: Keys.authToken)
    }

    func retrieveAuthToken() -> String? {
        retrieve(forKey: Keys.authToken)
    }

    func saveRefreshToken(_ token: String) -> Bool {
        save(token, forKey: Keys.refreshToken)
    }

    func retrieveRefreshToken() -> String? {
        retrieve(forKey: Keys.refreshToken)
    }

    func saveUserID(_ userID: String) -> Bool {
        save(userID, forKey: Keys.userID)
    }

    func retrieveUserID() -> String? {
        retrieve(forKey: Keys.userID)
    }

    func clearAuthData() {
        _ = delete(forKey: Keys.authToken)
        _ = delete(forKey: Keys.refreshToken)
        _ = delete(forKey: Keys.userID)
    }
}
