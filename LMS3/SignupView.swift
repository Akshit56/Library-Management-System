//
//  SignupView.swift
//  LMS3
//
//  Created by Aditya Majumdar on 20/04/24.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct SignupView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var dob: String = ""
    @State private var password: String = ""
    @State private var selectedUserType: UserType = .admin // Default user type

    @State private var isSignedUp: Bool = false // State to track signup status
    @State private var signupError: String? // State to track signup error

    var body: some View {
        NavigationView {
            VStack {
                Picker("Select User Type", selection: $selectedUserType) {
                    Text("Admin").tag(UserType.admin)
                    Text("Librarian").tag(UserType.librarian)
                    Text("Member").tag(UserType.member)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                TextField("Name", text: $name)
                    .padding()
                TextField("Email", text: $email)
                    .padding()
                    .autocapitalization(.none)
                TextField("Date of Birth", text: $dob)
                    .padding()
                SecureField("Password", text: $password)
                    .padding()
                    .autocapitalization(.none)

                if let error = signupError {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }

                Button("Signup") {
                    signUpUser()
                }
                .padding()

                NavigationLink(
                    destination: destinationView(),
                    isActive: $isSignedUp,
                    label: { EmptyView() }
                )
                .hidden()
            }
            .navigationTitle("Signup")
        }
    }

    private func signUpUser() {
        guard !name.isEmpty, !email.isEmpty, !dob.isEmpty, !password.isEmpty else {
            signupError = "Please fill in all fields."
            return
        }

        // Firebase authentication to create user
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { [self] (result, error) in
            if let error = error {
                signupError = error.localizedDescription
            } else if let authResult = result {
                // Authentication successful, store user details in Firestore
                let userData: [String: Any] = [
                    "name": name,
                    "email": email,
                    "dob": dob,
                    "userType": selectedUserType.rawValue // Store user type in Firestore
                ]

                let userRef = Firestore.firestore().collection("Users").document(authResult.user.uid)
                userRef.setData(userData) { error in
                    if let error = error {
                        signupError = "Failed to store user data: \(error.localizedDescription)"
                    } else {
                        isSignedUp = true // Update signup status
                    }
                }
            }
        }
    }



    private func destinationView() -> some View {
        switch selectedUserType {
        case .admin:
            return AnyView(AdminHomeView())
        case .librarian:
            return AnyView(LibrarianHomeView())
        case .member:
            return AnyView(MemberHomeView())
        }
    }
}


struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
