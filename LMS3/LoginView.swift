//
//  LoginView.swift
//  LMS3
//
//  Created by Aditya Majumdar on 20/04/24.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var selectedUserType: UserType = .admin // Default user type

    @State private var isLoggedIn: Bool = false // State to track login status
    @State private var loginError: String? // State to track login error
    @State private var showAlert: Bool = false // State to control alert presentation

    var body: some View {
        NavigationView {
            VStack {
                Image("books1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 80)
                    .padding(.top, 60)

                Text("Welcome Back!")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)
                    .padding(.bottom, 50)

                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .autocapitalization(.none)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .autocapitalization(.none)

                    Picker("Select User Type", selection: $selectedUserType) {
                        Text("Admin").tag(UserType.admin)
                        Text("Librarian").tag(UserType.librarian)
                        Text("Member").tag(UserType.member)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    Button("Log In") {
                        loginUser()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.top, 20)
                    
                    NavigationLink(
                        destination: destinationView(),
                        isActive: $isLoggedIn,
                        label: { EmptyView() }
                    )
                    .hidden()

                    HStack{
                        Spacer()

                        NavigationLink(destination: SignupView().navigationBarBackButtonHidden()) {
                            Text("Sign Up")
                                .foregroundColor(.blue)
                                .padding(.horizontal)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(loginError ?? "An error occurred."), dismissButton: .default(Text("OK")))
                }
            }
        }
    }

    private func loginUser() {
        guard !email.isEmpty, !password.isEmpty else {
            loginError = "Please enter email and password."
            showAlert = true
            return
        }

        // Firebase authentication to sign in user
        Auth.auth().signIn(withEmail: email, password: password) { [self] (result, error) in
            if let error = error {
                loginError = error.localizedDescription
                showAlert = true
            } else if let authResult = result {
                // Authentication successful, fetch user details from Firestore
                let userRef = Firestore.firestore().collection("Users").document(authResult.user.uid)
                userRef.getDocument { document, error in
                    if let error = error {
                        loginError = "Failed to fetch user data: \(error.localizedDescription)"
                        showAlert = true
                    } else if let userData = document?.data(),
                              let userTypeString = userData["userType"] as? String,
                              let userType = UserType(rawValue: userTypeString) {
                        // Verify user type
                        if userType == selectedUserType {
                            isLoggedIn = true // Update login status
                        } else {
                            loginError = "Invalid user type for login."
                            showAlert = true
                        }
                    } else {
                        loginError = "User not found or invalid data."
                        showAlert = true
                    }
                }
            }
        }
    }
    private func destinationView() -> some View {
        switch selectedUserType {
        case .admin:
            return AnyView(AdminHomeView().navigationBarBackButtonHidden())
        case .librarian:
            return AnyView(LibrarianHomeView().navigationBarBackButtonHidden())
        case .member:
            return AnyView(MemberHomeView().navigationBarBackButtonHidden())
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
