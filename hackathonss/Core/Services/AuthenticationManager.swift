import Foundation
import SwiftUI

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var isAuthenticated: Bool {
        didSet {
            UserDefaults.standard.set(isAuthenticated, forKey: "isUserAuthenticated")
        }
    }
    
    // Store user's registered name
    @Published var registeredUserName: String? {
        didSet {
            if let name = registeredUserName {
                UserDefaults.standard.set(name, forKey: "registeredUserName")
            } else {
                UserDefaults.standard.removeObject(forKey: "registeredUserName")
            }
        }
    }
    
    private init() {
        self.isAuthenticated = UserDefaults.standard.bool(forKey: "isUserAuthenticated")
        self.registeredUserName = UserDefaults.standard.string(forKey: "registeredUserName")
    }
    
    func signIn(email: String, password: String) async -> Bool {
        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In a real app, validate credentials with backend
        guard !email.isEmpty, !password.isEmpty else {
            return false
        }
        
        await MainActor.run {
            isAuthenticated = true
            NotificationCenter.default.post(name: NSNotification.Name("UserDidAuthenticate"), object: nil)
        }
        
        return true
    }
    
    func signUp(name: String, email: String, password: String) async -> Bool {
        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In a real app, create user with backend
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            return false
        }
        
        await MainActor.run {
            // Store the registered name
            registeredUserName = name
            isAuthenticated = true
            NotificationCenter.default.post(name: NSNotification.Name("UserDidAuthenticate"), object: nil)
        }
        
        return true
    }
    
    func logout() {
        isAuthenticated = false
        registeredUserName = nil
        UserDefaults.standard.set(false, forKey: "isUserAuthenticated")
        NotificationCenter.default.post(name: NSNotification.Name("UserDidLogout"), object: nil)
    }
    
    func resetPassword(email: String) async -> Bool {
        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In a real app, send password reset email
        return !email.isEmpty
    }
}
