//
//  FirebaseAuthManager.swift
//  LMS3
//
//  Created by Aditya Majumdar on 20/04/24.
//

import FirebaseAuth

enum UserType: String {
    case admin = "Admin"
    case librarian = "Librarian"
    case member = "Member"
}

class FirebaseAuthManager {
    static let shared = FirebaseAuthManager()

    private init() {}

    func login(email: String, password: String, userType: UserType, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [self] (result, error) in
            if let user = result?.user {
                // Check user type and handle accordingly
                self.navigateToLandingView(userType: userType)
                completion(.success(user))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }

    func signup(name: String, email: String, dob: String, password: String, userType: UserType, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [self] (result, error) in
            if let user = result?.user {
                // Optionally update user profile (name, dob, etc.) here
                self.navigateToLandingView(userType: userType)
                completion(.success(user))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }

    func signout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    private func navigateToLandingView(userType: UserType) {
        switch userType {
        case .admin:
            // Navigate to Admin landing view
            print("Navigate to Admin landing view")
        case .librarian:
            // Navigate to Librarian landing view
            print("Navigate to Librarian landing view")
        case .member:
            // Navigate to Member landing view
            print("Navigate to Member landing view")
        }
    }
}
