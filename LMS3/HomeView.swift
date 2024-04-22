//
//  HomeView.swift
//  LMS3
//
//  Created by Aditya Majumdar on 20/04/24.
//

import SwiftUI


struct ScannerViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewController {
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        // Optional: Implement update logic if needed
    }
}
struct AdminHomeView: View {
    var body: some View {
        Text("Welcome Admin!")
    }
}

struct LibrarianHomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome Librarian!")
                
                // Navigate to ScannerViewController
                NavigationLink(destination: ScannerViewController()) {
                    Text("Scan Book")
                }
            }
        }
    }
}

struct MemberHomeView: View {
    var body: some View {
        Text("Welcome Member!")
    }
}
