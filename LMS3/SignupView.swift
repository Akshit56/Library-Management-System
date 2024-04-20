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
    @State private var dob: Date = Date()
    @State private var password: String = ""
    @State private var selectedUserType: UserType = .admin

    @State private var isSignedUp: Bool = false
    @State private var signupError: String?
    @State private var showAlert: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Come and join the gang!")
                        .font(.largeTitle).bold()
                        .foregroundColor(.black)
                    Image("books1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 60)
                }
                .padding(.top, 50)
                .padding(.bottom,50)

                VStack(spacing: 20) {
                    TextField("Name", text: $name)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)

                    TextField("Email", text: $email)
                        .padding()
                        .autocapitalization(.none)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)

                    DatePicker("Date of Birth", selection: $dob, displayedComponents: .date)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)


                    SecureField("Password", text: $password)
                        .padding()
                        .autocapitalization(.none)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)

                    Picker("Select User Type", selection: $selectedUserType) {
                        Text("Admin").tag(UserType.admin)
                        Text("Librarian").tag(UserType.librarian)
                        Text("Member").tag(UserType.member)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    Button("Sign Up") {
                        signUpUser()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    NavigationLink(
                                        destination: destinationView(),
                                        isActive: $isSignedUp,
                                        label: { EmptyView() }
                                    )
                                    .hidden()

                    NavigationLink(
                        destination: LoginView().navigationBarBackButtonHidden(),
                        label: {
                            HStack {
                                Text("Already have an account?")
                                    .foregroundColor(.black)
                                Text("Login")
                                    .foregroundColor(.blue)
                            }
                        }
                    )

                    Spacer()
                }
                .padding(.horizontal, 20)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(signupError ?? "An error occurred."), dismissButton: .default(Text("OK")))
                }
            }
        }
    }

    private func signUpUser() {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            signupError = "Please fill in all fields."
            showAlert = true
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [self] (result, error) in
            if let error = error {
                signupError = error.localizedDescription
                showAlert = true
            } else if let authResult = result {
                let userData: [String: Any] = [
                    "name": name,
                    "email": email,
                    "dob": dob,
                    "userType": selectedUserType.rawValue
                ]

                let userRef = Firestore.firestore().collection("Users").document(authResult.user.uid)
                userRef.setData(userData) { error in
                    if let error = error {
                        signupError = "Failed to store user data: \(error.localizedDescription)"
                        showAlert = true
                    } else {
                        isSignedUp = true
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

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}

