//
//  LMS3App.swift
//  LMS3
//
//  Created by Aditya Majumdar on 19/04/24.
//

import SwiftUI
import Firebase

@main
struct LMS3App: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
