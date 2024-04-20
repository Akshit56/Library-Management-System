//
//  ContentView.swift
//  LMS3
//
//  Created by Aditya Majumdar on 19/04/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: LoginView().navigationBarBackButtonHidden()) {
                    Text("Login")
                }
                NavigationLink(destination: SignupView().navigationBarBackButtonHidden()) {
                    Text("Signup")
                }
            }
            .navigationTitle("Welcome")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
