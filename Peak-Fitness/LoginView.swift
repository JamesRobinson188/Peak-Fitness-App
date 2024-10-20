//
//  LoginView.swift
//  Peak-Fitness
//
//  Created by James Robinson on 21/07/2024.
//

import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var message: String = ""
    @State private var showingAlert = false
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5.0)
                .padding(.bottom, 20)

            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5.0)
                .padding(.bottom, 20)

            Button(action: {
                APIService.shared.login(username: username, password: password) { result in
                    switch result {
                    case .success(let message):
                        DispatchQueue.main.async {
                            self.message = message
                            self.navigationManager.navigate(to: .tabView)
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self.message = error.localizedDescription
                            self.showingAlert = true
                        }
                    }
                }
            }) {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(Color.blue)
                    .cornerRadius(15.0)
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Login Status"), message: Text(message), dismissButton: .default(Text("OK")))
            }

            Button(action: {
                self.navigationManager.navigate(to: .register)
            }) {
                Text("Don't have an account? Register")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.top, 20)
            }
        }
        .padding()
    }
}
